---
name: "iih-booking-system"
description: "Set strict Aisha facility bookings signature."
---

# Update Proposal: Strict Aisha Facility Booking Signature

## Rule
All outbound emails from Aisha using `facilitybookings@iih.ng` must use the approved signature format. Do not include phone numbers. Do not include `Powered by IHS` unless Temi explicitly requests it in the current thread.

## Identity Details
- Name: Aisha
- Job title: IIH Facility Booking AI Agent
- Organization: Ilorin Innovation Hub
- Website: www.iih.ng
- Address: Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria

## HTML Signature
```html
<div style="clear: both;">
 Warm regards,
 <br>
 <br>
</div>
<div style="font-family: Arial, sans-serif; font-size: 14px; color: #333; line-height: 1.5;">
 <div>
 <table class="ze_tableView" cellpadding="2" cellspacing="2" border="0" style="font-size: 10pt; font-family: Arial, Helvetica, sans-serif; border-collapse: collapse; border: 0px solid black; color: black;">
 <tbody>
 <tr>
 <td style="vertical-align: top; width: 158.141px;">
 <div>
 <img src="/zm/ImageSignature?fileName=1749122382045004_1686933120.png&amp;accountId=3859712000000008002&amp;storeName=709990578&amp;frm=org&amp;zoid=709990578" width="155" height="74" style="float: left;" orig_width="371" orig_height="181">
 <br>
 </div>
 </td>
 <td style="vertical-align: top; width: 645.859px;">
 <div style="font-family: Arial, sans-serif; font-size: 14px; color: #333; line-height: 1.5;">
 <div>
 <div>
 <b>
 <span class="size" style="font-size:10.6667px">
 Aisha
 <br>
 </span>
 </b>
 <span class="size" style="font-size:10.6667px">
 IIH Facility Booking AI Agent&nbsp;|
 <span class="colour" style="color:rgb(0, 204, 0)">
 Ilorin Innovation Hub
 </span>
 <span class="colour" style="color: rgb(106, 168, 79); font-weight: 500;">
 <br>
 </span>
 </span>
 <a target="_blank" style="color: #1a73e8;" href="https://iih.ng">
 <span class="size" style="font-size:10.6667px">
 www.iih.ng
 </span>
 </a>
 <span class="size" style="font-size:10.6667px">
 <br>
 Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria
 </span>
 <br>
 </div>
 </div>
 </div>
 </td>
 </tr>
 </tbody>
 </table>
 <p>
 <span class="colour" style="color:rgb(153, 153, 153)">
 <span class="size" style="font-size:10.6667px">
 This message and any attachments are confidential and intended only for the recipient.&nbsp;
 </span>
 </span>
 <br>
 </p>
 </div>
</div>
<div style="clear: both;">
 <br>
</div>
```

## Plain Text Fallback
```text
Warm regards,

Aisha
IIH Facility Booking AI Agent | Ilorin Innovation Hub
www.iih.ng
Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria

This message and any attachments are confidential and intended only for the recipient.
```

## Enforcement
Use this signature for booking replies, invoice emails, payment reminders, and internal booking coordination emails sent from `facilitybookings@iih.ng`.
