#!/usr/bin/env python3
"""Acceptance checks for IIH booking system v1.2 improvements.

The checks use temporary SQLite databases and dry-run composition only. They do
not contact clients, Zoho Books, Zoho Calendar, or SMTP.
"""

from __future__ import annotations

import copy
import sys
import tempfile
from types import SimpleNamespace
from datetime import datetime, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import iih_booking_agent as agent  # noqa: E402
import iih_booking_connectors as connectors  # noqa: E402
import iih_booking_quote as quote  # noqa: E402


BASE_BOOKING = {
    "full_name": "Ada Client",
    "email": "ada@example.com",
    "phone": "+2348000000000",
    "organization": "Ada Org",
    "facility": "Main Hall",
    "event_name": "Ada Demo Day",
    "event_type": "Conference",
    "event_date": "2026-07-20",
    "start_time": "09:00",
    "end_time": "17:00",
    "duration_hours": 8,
    "expected_attendance": 100,
    "catering_mode": "hub",
    "external_catering": False,
    "av_needs": "Projector",
    "setup_needs": "Theatre",
    "refreshment_selection": "None",
    "sensitive_content_flag": False,
}


def check(condition: bool, name: str) -> None:
    if not condition:
        raise AssertionError(name)
    print(f"PASS {name}")


def make_record(
    message_id: str,
    subject: str,
    body: str,
    sender: str = "client@example.com",
    to: str = "facilitybookings@iih.ng",
    cc: str = "",
    has_attachment: bool = False,
) -> agent.MessageRecord:
    return agent.MessageRecord(
        envelope_id=message_id,
        subject=subject,
        sender_email=sender,
        sender_name="Client",
        date="2026-06-17",
        has_attachment=has_attachment,
        body=body,
        headers={
            "message-id": message_id,
            "to": to,
            "cc": cc,
            "authentication-results": "spf=pass dkim=pass dmarc=pass",
        },
        raw={"id": message_id, "subject": subject},
    )


def main() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        connectors.REGISTER_PATH = tmp_path / "booking_register.sqlite3"
        agent.STATE_PATH = tmp_path / "booking_agent.sqlite3"

        connectors.migrate()

        first = copy.deepcopy(BASE_BOOKING)
        second = copy.deepcopy(BASE_BOOKING)
        second["organization"] = "Second Org"
        second["email"] = "second@example.com"
        second["event_name"] = "Competing Event"
        second["start_time"] = "10:00"
        second["end_time"] = "16:00"
        first_hold = connectors.create_hold(first, status="Invoice Sent")
        second_hold = connectors.create_hold(second, status="Invoice Sent")
        check(first_hold["held"] and second_hold["blocked"], "competing booking blocked after invoice-sent hold")

        reminder_as_of = connectors.cutoff_for_event(first["event_date"]) - timedelta(hours=47)
        reminders = connectors.holds_needing_payment_reminder(reminder_as_of)
        released = connectors.release_expired_holds(connectors.cutoff_for_event(first["event_date"]))
        check(reminders["reminder_due"] >= 1 and released["released"] >= 1 and released["notify_events"], "hold reminder and auto-release")

        sunday = copy.deepcopy(BASE_BOOKING)
        sunday["event_date"] = "2026-07-19"
        out_of_hours = copy.deepcopy(BASE_BOOKING)
        out_of_hours["end_time"] = "18:00"
        over_capacity = copy.deepcopy(BASE_BOOKING)
        over_capacity["expected_attendance"] = 401
        check(any(flag["code"] == "blackout_day" for flag in quote.intake_flags(sunday)), "Sunday request flagged")
        check(any(flag["code"] == "outside_operating_window" for flag in quote.intake_flags(out_of_hours)), "out-of-hours request flagged")
        check(any(flag["code"] == "attendance_exceeds_capacity" for flag in quote.intake_flags(over_capacity)), "over-capacity request flagged")

        cancel = connectors.cancellation_terms("IIH-BOOK-TEST")
        first_reschedule = connectors.reschedule_terms("IIH-BOOK-TEST", "2026-07-20", "2026-07-16", 0)
        second_reschedule = connectors.reschedule_terms("IIH-BOOK-TEST", "2026-07-20", "2026-07-16", 1)
        check(cancel["cancellation_fee_percent"] == 30 and cancel["refund_percent"] == 70, "cancellation fee and refund terms")
        check(first_reschedule["fee"] == 0 and second_reschedule["status"] == "Cancelled With Fee", "reschedule terms")

        deposit = connectors.deposit_resolution("IIH-BOOK-TEST", damage_amount=25000)
        check(deposit["route_to"] == ["events@iih.ng", "finance@iih.ng"] and not deposit["refund_instruction_allowed"], "deposit resolution routed before refund")

        invoice_payload = connectors.build_invoice_payload("CONTACT", BASE_BOOKING)
        facility_line = invoice_payload["line_items"][0]
        deposit_line = invoice_payload["line_items"][1]
        check(facility_line.get("tax_percentage") == 7.5 and "tax_percentage" not in deposit_line, "VAT applied to taxable item and excluded from deposit")

        with agent.ensure_db() as conn:
            clear_new = make_record("<clear-new@example.com>", "Facility booking", "I would like to book the Main Hall.")
            clear_decision = agent.classify(clear_new, conn, "clear-thread", "new_thread")
            check(clear_decision["classification"] == "new_booking_request", "clear external new booking request allowed")

            events_new = make_record(
                "<events-new@example.com>",
                "Facility booking",
                "I would like to book the Main Hall.",
                to="events@iih.ng",
            )
            events_new_decision = agent.classify(events_new, conn, "events-new-thread", "new_thread")
            check(events_new_decision["classification"] == "new_booking_request", "external new booking to Events group allowed")

            generic_event = make_record("<generic-event@example.com>", "Upcoming event", "Here is an update about the event.")
            generic_decision = agent.classify(generic_event, conn, "generic-thread", "new_thread")
            check(generic_decision["classification"] == "requires_human_review", "generic event language does not auto-qualify")

            unknown_followup = make_record("<unknown-followup@example.com>", "Re: Facility booking", "Following up on our request.")
            followup_decision = agent.classify(unknown_followup, conn, "unknown-followup-thread", "new_thread")
            check(followup_decision["classification"] == "requires_human_review", "unknown follow-up waits for instruction")

            internal_fyi = make_record(
                "<internal-fyi@iih.ng>",
                "Event update",
                "Looping Maureen in.",
                sender="adebola@iih.ng",
                to="events@iih.ng",
            )
            internal_fyi_decision = agent.classify(internal_fyi, conn, "internal-fyi-thread", "new_thread")
            check(
                internal_fyi_decision["classification"] == "internal_fyi_not_addressed_to_booking"
                and internal_fyi_decision["next_action"] == "no_response_record_only",
                "internal email to Events group is no-response FYI",
            )

            internal_direct_ask = make_record(
                "<internal-direct-ask@iih.ng>",
                "Booking help",
                "Aisha, please advise on this booking.",
                sender="adebola@iih.ng",
                to="events@iih.ng",
            )
            internal_direct_ask_decision = agent.classify(internal_direct_ask, conn, "internal-direct-ask-thread", "new_thread")
            check(
                internal_direct_ask_decision["classification"] == "requires_human_review",
                "internal Events email directly asking Aisha is reviewed",
            )

            internal_direct = make_record(
                "<internal-direct@iih.ng>",
                "Booking support",
                "Please advise on this booking.",
                sender="maureen.okey@iih.ng",
            )
            internal_direct_decision = agent.classify(internal_direct, conn, "internal-direct-thread", "new_thread")
            check(
                internal_direct_decision["classification"] == "requires_human_review",
                "internal email addressed to booking is assessed, not ignored",
            )

            form_new = make_record(
                "<form-new@google.com>",
                "New response: Facility booking",
                "Google Forms new response",
                sender="forms-receipts-noreply@google.com",
            )
            form_new_decision = agent.classify(form_new, conn, "form-new-thread", "new_thread")
            check(
                form_new_decision["classification"] == "form_submission_new_booking"
                and form_new_decision["next_action"] == "review_new_form_submission_no_reply_to_google_prepare_booking_workflow",
                "new Google Form booking submission is recognized without reply",
            )

            record = make_record("<dup@example.com>", "Facility booking", "I want to book the Main Hall.")
            thread_key = "client@example.com|facility booking"
            decision = {"classification": "new_booking_request", "next_action": "deduce_intake", "thread_reason": "new_thread"}
            first_insert = agent.store_message(conn, record, thread_key, decision)
            second_insert = agent.store_message(conn, record, thread_key, decision)
            response_one = agent.send_template_response(conn, thread_key, record, decision, dry_run=True)
            response_two = agent.send_template_response(conn, thread_key, record, decision, dry_run=True)
            check(first_insert and not second_insert and response_one == "dry-run" and response_two is None, "message and template dedup suppression")

            agent.state_set(conn, "current_run_sends", 10)
            allowed, reason = agent.send_budget_available(conn)
            check(not allowed and reason == "max_sends_per_run_exceeded", "send circuit breaker trips on burst")
            conn.commit()

        agent.STATE_PATH = tmp_path / "watchdog.sqlite3"
        with agent.ensure_db() as conn:
            agent.state_set(conn, "last_successful_poll", (datetime.now() - timedelta(minutes=45)).isoformat(timespec="seconds"))
            conn.commit()
        check(agent.watchdog()["alert"], "watchdog alerts on stale poll")

        agent.STATE_PATH = tmp_path / "auth.sqlite3"
        agent.read_message = lambda _envelope_id: (
            {"message-id": "<pay@example.com>", "authentication-results": "spf=fail dkim=fail dmarc=fail"},
            "Attached is payment proof for invoice 123.",
        )
        result = None
        with agent.ensure_db() as conn:
            result = agent.process_envelope(
                conn,
                {"id": "1", "subject": "Payment proof", "from": {"addr": "payer@example.com", "name": "Payer"}, "has_attachment": True},
                auto_respond=False,
            )
            conn.commit()
        check(result["classification"] == "unauthenticated_payment_claim", "unauthenticated payment claim does not advance state")

        agent.STATE_PATH = tmp_path / "link.sqlite3"
        with agent.ensure_db() as conn:
            for idx in range(2):
                conn.execute(
                    """
                    INSERT INTO conversations (thread_key, normalized_subject, subject, client_email, status, next_action, updated_at)
                    VALUES (?, ?, ?, ?, 'Draft', 'review', ?)
                    """,
                    (f"thread-{idx}", "host event", "Ada Org Main Hall 2026-07-20", f"other{idx}@example.com", agent.now()),
                )
            conn.commit()
        link = agent.resolve_form_link("different@example.com", "Ada Org", "2026-07-20", "Main Hall")
        check(link["manual_review"] and link["reason"] == "ambiguous_fallback_match", "ambiguous form link routes to manual review")

        dry_db = tmp_path / "dry.sqlite3"
        agent.STATE_PATH = dry_db
        with agent.ensure_db() as conn:
            record = make_record("<dry@example.com>", "Facility booking", "Please book a hall.")
            decision = {"classification": "new_booking_request", "next_action": "deduce_intake", "thread_reason": "new_thread"}
            dry = agent.send_template_response(conn, "dry-thread", record, decision, dry_run=True)
            check(dry == "dry-run", "dry-run composes without sending")

        external = copy.deepcopy(BASE_BOOKING)
        external["catering_mode"] = "external"
        external["external_catering"] = True
        external_quote = quote.build_quote(external)
        check(any(item["name"] == "External Catering Corkage Fee" and item["rate"] == 100000 for item in external_quote["line_items"]), "external catering corkage applied")

        # --- Confirmation guard: refuse without invoice/payment/finance/availability ---
        guard_db = tmp_path / "guard.sqlite3"
        agent.STATE_PATH = guard_db
        with agent.ensure_db() as conn:
            conn.execute(
                """
                INSERT INTO conversations (thread_key, normalized_subject, subject, client_email, status, next_action, updated_at)
                VALUES ('guard-thread', 'guard', 'Guard', 'guard@example.com', 'Draft', 'quote', ?)
                """,
                (agent.now(),),
            )
            conn.commit()
        refused = False
        try:
            agent.mark_confirmed(SimpleNamespace(thread_key="guard-thread", calendar_event_uid="", confirmed_by="test"))
        except SystemExit:
            refused = True
        check(refused, "mark-confirmed refused with no invoice/payment/finance/availability")
        with agent.ensure_db() as conn:
            logged = conn.execute(
                "SELECT count(*) FROM action_log WHERE thread_key='guard-thread' AND action='confirmation_refused_guard_failed'"
            ).fetchone()[0]
        check(logged == 1, "refused confirmation is recorded in action_log")

        # --- Full evidence chain then confirm succeeds ---
        agent.record_availability_check(SimpleNamespace(thread_key="guard-thread", evidence="events calendar free", available=1))
        with agent.ensure_db() as conn:
            conn.execute(
                """
                UPDATE conversations SET invoice_id='INV-1', invoice_number='INV-000001',
                    invoice_total=750000, invoice_status='sent' WHERE thread_key='guard-thread'
                """
            )
            conn.commit()
        agent.record_payment_proof(SimpleNamespace(thread_key="guard-thread", reference="TRF-1", amount=750000, payer="Ada"))
        agent.mark_finance_confirmed(SimpleNamespace(thread_key="guard-thread", reference="FIN-1"))
        confirmed = agent.mark_confirmed(SimpleNamespace(thread_key="guard-thread", calendar_event_uid="CAL-1", confirmed_by="test"))
        check(confirmed["status"] == "Confirmed", "mark-confirmed succeeds once all gates are satisfied")

        # --- updatedAt CAS guard on invoice recording ---
        cas_db = tmp_path / "cas.sqlite3"
        agent.STATE_PATH = cas_db
        with agent.ensure_db() as conn:
            conn.execute(
                """
                INSERT INTO conversations (thread_key, normalized_subject, subject, client_email, status, next_action, updated_at)
                VALUES ('cas-thread', 'cas', 'CAS', 'cas@example.com', 'Draft', 'quote', '2026-07-01T10:00:00')
                """
            )
            conn.commit()
        stale_refused = False
        try:
            agent.record_invoice(SimpleNamespace(thread_key="cas-thread", invoice_id="I1", invoice_number="N1", amount=100, expected_updated_at="2026-07-01T09:00:00"))
        except SystemExit:
            stale_refused = True
        check(stale_refused, "record-invoice refuses when the conversation revision changed")
        fresh_ok = agent.record_invoice(SimpleNamespace(thread_key="cas-thread", invoice_id="I1", invoice_number="N1", amount=100, expected_updated_at="2026-07-01T10:00:00"))
        check(fresh_ok["ok"] is True, "record-invoice succeeds when the revision matches")

        # --- Day-rate quantity: multi-day booking is charged per day ---
        multi = copy.deepcopy(BASE_BOOKING)
        multi["event_days"] = 3
        multi_quote = quote.build_quote(multi)
        hall_line = next(item for item in multi_quote["line_items"] if item["name"] == "Main Hall")
        check(hall_line["quantity"] == 3 and hall_line["amount"] == 3 * 750000, "multi-day day-rate booking charged per day")

        single = copy.deepcopy(BASE_BOOKING)
        single_quote = quote.build_quote(single)
        single_line = next(item for item in single_quote["line_items"] if item["name"] == "Main Hall")
        check(single_line["quantity"] == 1, "single-day day-rate booking charged once")

        # --- run_cmd retries on timeout ---
        import subprocess as _sp
        calls = {"n": 0}
        real_run = _sp.run
        def flaky_run(*a, **k):
            calls["n"] += 1
            if calls["n"] < 2:
                raise _sp.TimeoutExpired(cmd="himalaya", timeout=30)
            return SimpleNamespace(stdout="ok", returncode=0)
        agent.time.sleep = lambda *_: None
        _sp.run = flaky_run
        try:
            out = agent.run_cmd(["himalaya"], timeout=30, retries=3, base_delay=0)
        finally:
            _sp.run = real_run
        check(out == "ok" and calls["n"] == 2, "run_cmd retries once on timeout then succeeds")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
