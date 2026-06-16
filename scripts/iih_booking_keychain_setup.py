#!/usr/bin/env python3
"""Prompt for IIH booking secrets and save them to macOS Keychain.

Values are never printed. Service names match scripts/iih_booking_connectors.py:
  iih-booking-ZOHO_CLIENT_ID
  iih-booking-ZOHO_CLIENT_SECRET
  iih-booking-ZOHO_REFRESH_TOKEN
  iih-booking-ZOHO_BOOKS_ORG_ID
  iih-booking-ZOHO_APP_PASSWORD
  iih-booking-ZOHO_CALENDAR_UID
"""

from __future__ import annotations

import argparse
import getpass
import subprocess
from dataclasses import dataclass


ACCOUNT = "iih-booking"


@dataclass(frozen=True)
class SecretPrompt:
    name: str
    label: str
    required: bool = True
    hidden: bool = True

    @property
    def service(self) -> str:
        return f"iih-booking-{self.name}"


PROMPTS = [
    SecretPrompt("ZOHO_CLIENT_ID", "Zoho Client ID"),
    SecretPrompt("ZOHO_CLIENT_SECRET", "Zoho Client Secret"),
    SecretPrompt("ZOHO_REFRESH_TOKEN", "Zoho Refresh Token"),
    SecretPrompt("ZOHO_BOOKS_ORG_ID", "Zoho Books Org ID", hidden=False),
    SecretPrompt("ZOHO_APP_PASSWORD", "Zoho app password for facilitybookings@iih.ng"),
    SecretPrompt("ZOHO_CALENDAR_UID", "Zoho Calendar UID for booking calendar", required=False, hidden=False),
]


def keychain_has(service: str) -> bool:
    result = subprocess.run(
        ["security", "find-generic-password", "-s", service, "-a", ACCOUNT],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return result.returncode == 0


def save_secret(prompt: SecretPrompt, value: str) -> None:
    subprocess.run(
        [
            "security",
            "add-generic-password",
            "-U",
            "-s",
            prompt.service,
            "-a",
            ACCOUNT,
            "-w",
            value,
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )


def collect(prompt: SecretPrompt) -> str:
    suffix = " (optional, press Enter to skip)" if not prompt.required else ""
    if prompt.hidden:
        return getpass.getpass(f"{prompt.label}{suffix}: ").strip()
    return input(f"{prompt.label}{suffix}: ").strip()


def run_setup(overwrite: bool) -> int:
    print("IIH Booking Keychain Setup")
    print("Values are hidden where possible and will not be printed back.")
    print("Use facilitybookings@iih.ng for the Zoho app password/mailbox identity.")
    print("")

    for prompt in PROMPTS:
        if keychain_has(prompt.service) and not overwrite:
            print(f"- {prompt.name}: already saved")
            continue
        value = collect(prompt)
        if not value and prompt.required:
            print(f"- {prompt.name}: skipped, but required")
            continue
        if not value:
            print(f"- {prompt.name}: skipped")
            continue
        save_secret(prompt, value)
        print(f"- {prompt.name}: saved")

    print("")
    print("Run: python3 scripts/iih_booking_connectors.py doctor --pretty")
    return 0


def run_check() -> int:
    for prompt in PROMPTS:
        print(f"{prompt.name}: {'saved' if keychain_has(prompt.service) else 'missing'}")
    print("ZOHO_EMAIL: default facilitybookings@iih.ng")
    print("ZOHO_FROM: default facilitybookings@iih.ng")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--overwrite", action="store_true", help="Replace existing keychain items.")
    parser.add_argument("--check", action="store_true", help="Show saved/missing status without values.")
    args = parser.parse_args()
    if args.check:
        return run_check()
    return run_setup(overwrite=args.overwrite)


if __name__ == "__main__":
    raise SystemExit(main())
