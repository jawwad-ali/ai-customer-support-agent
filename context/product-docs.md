# Kanbix — Product Documentation

## 1. Getting Started

### Creating Your Account
1. Go to **kanbix.io/signup**
2. Enter your email and create a password (or sign up with Google/GitHub)
3. Verify your email address
4. Choose your plan (Free trial available for all paid plans)
5. Complete onboarding: set your team name and invite members

### Creating Your First Board
1. Click **"+ New Board"** from the dashboard
2. Choose a blank board or pick a template (Sprint Planning, Content Calendar, etc.)
3. Name your board and set visibility (Private, Team, or Public)
4. Add lists/columns (e.g., "To Do", "In Progress", "Review", "Done")
5. Start adding cards to your lists

### Inviting Team Members
1. Go to **Settings > Team Members**
2. Click **"Invite"** and enter email addresses
3. Assign a role: **Admin**, **Member**, or **Viewer**
4. Invitees receive an email with a join link
5. They'll appear in your team once they accept

> **Note:** Free plan supports 1 user only. Upgrade to Starter for team features.

---

## 2. Core Features

### Boards
- Each board represents a project or workflow
- Boards contain **lists** (columns) that represent stages
- Default lists: To Do, In Progress, Done (fully customizable)
- Board settings: background color, visibility, starred/favorites
- **Board limits:** Free = 3 boards, Starter/Pro = unlimited

### Lists (Columns)
- Represent stages in your workflow
- Drag to reorder lists
- Set **WIP limits** (Work-In-Progress) to cap cards per list
- Archive lists to declutter without deleting

### Cards
Cards are the core unit of work. Each card supports:
- **Title** and **Description** (Markdown supported)
- **Assignees** — assign one or multiple team members
- **Due Date** — with optional reminder notifications (1 day before, 1 hour before)
- **Labels** — color-coded tags (e.g., "Bug", "Feature", "Urgent")
- **Checklists** — subtask lists with progress tracking
- **Attachments** — upload files (max 25MB per file) or link from Google Drive
- **Comments** — threaded discussion with @mentions
- **Activity Log** — full history of changes
- **Custom Fields** (Pro+) — add text, number, date, or dropdown fields
- **Card limits:** Free = 100 cards total, Starter/Pro = unlimited

### Labels
- 8 default colors available
- Custom label names (e.g., red = "Critical", green = "Done")
- Filter board view by label
- Labels are shared across all boards in a workspace

### Due Dates & Reminders
- Set due date and optional due time on any card
- Reminder options: None, At time of due date, 1 hour before, 1 day before, 2 days before
- Overdue cards highlighted in red on the board
- Calendar view shows all cards with due dates

---

## 3. Workflow Automations

> Available on **Starter** (5 automations) and **Pro/Enterprise** (unlimited)

### How Automations Work
An automation consists of a **Trigger** and one or more **Actions**:

```
WHEN [trigger] → THEN [action(s)]
```

### Available Triggers
| Trigger                  | Description                              |
|--------------------------|------------------------------------------|
| Card created             | When a new card is added to any list     |
| Card moved               | When a card moves to a specific list     |
| Due date reached         | When a card's due date arrives           |
| Label added              | When a specific label is applied         |
| Checklist completed      | When all checklist items are checked     |
| Card assigned            | When a member is assigned to a card      |
| Comment added            | When someone comments on a card          |

### Available Actions
| Action                   | Description                              |
|--------------------------|------------------------------------------|
| Move card                | Move card to a specific list             |
| Assign member            | Auto-assign a team member                |
| Add label                | Apply a label to the card                |
| Send notification        | Notify via email or in-app               |
| Post to Slack            | Send message to a Slack channel          |
| Create card              | Create a new card in a specified list    |
| Set due date             | Set or adjust the due date               |
| Add comment              | Auto-add a comment to the card           |

### Automation Templates
- **Sprint Complete:** When card moves to "Done" → remove due date, add "Completed" label
- **Bug Triage:** When label "Bug" added → assign to QA lead, move to "Triage" list
- **Deadline Alert:** When due date is 1 day away → send Slack notification
- **Onboarding:** When new member joins board → create welcome card with checklist

### Automation Limits
- Free: No automations
- Starter: 5 automations per board
- Pro: Unlimited automations
- Enterprise: Unlimited + custom webhook triggers

### Troubleshooting Automations
- **Automation not firing:** Check that the trigger conditions match exactly. "Card moved to Done" won't fire if the list is named "Completed".
- **Duplicate actions:** If a card matches multiple automations, all will fire. Use conditions to avoid conflicts.
- **Slack integration required:** Slack actions require connecting your Slack workspace first (Settings > Integrations).

---

## 4. Integrations

### Slack
- **Setup:** Settings > Integrations > Slack > "Connect Workspace"
- **Features:**
  - Receive board notifications in Slack channels
  - Create cards from Slack messages (use `/kanbix create`)
  - Update card status from Slack
  - Use in automation actions
- **Troubleshooting:** If notifications stop, reconnect the integration. Tokens expire after 90 days.

### GitHub
- **Setup:** Settings > Integrations > GitHub > "Connect Repository"
- **Features:**
  - Link commits and PRs to cards
  - Auto-move cards when PR is merged
  - See branch status on card
- **Requires:** Pro plan or higher

### Google Drive
- **Setup:** Settings > Integrations > Google Drive > "Connect"
- **Features:**
  - Attach Drive files to cards without uploading
  - Preview docs, sheets, and slides inline
  - Auto-sync file updates
- **Available on:** All plans

### Zapier
- **Setup:** Connect via Zapier's Kanbix integration
- **Features:**
  - 1000+ app connections
  - Trigger Zaps on card events
  - Create cards from external tools
- **Available on:** Starter+ plans

### Webhooks (Pro+)
- **Setup:** Settings > Integrations > Webhooks > "Add Webhook"
- **Events:** card.created, card.moved, card.updated, card.deleted, comment.added
- **Payload:** JSON with event type, card data, board context, timestamp
- **Retry:** 3 attempts with exponential backoff

---

## 5. Team Management

### Roles & Permissions

| Role    | Boards          | Cards           | Settings | Billing |
|---------|-----------------|-----------------|----------|---------|
| Owner   | Create, delete  | Full access     | Full     | Full    |
| Admin   | Create, delete  | Full access     | Full     | View    |
| Member  | View assigned   | Edit assigned   | None     | None    |
| Viewer  | View only       | View + comment  | None     | None    |
| Guest   | Invited boards  | View + comment  | None     | None    |

### Guest Access
- Invite external collaborators (clients, contractors) as Guests
- Guests can only see boards they're explicitly invited to
- Guest actions: view cards, add comments, attach files
- Guests cannot create boards, lists, or automations
- **Limit:** Free = 0 guests, Starter = 5 guests, Pro = unlimited, Enterprise = unlimited

### Transferring Ownership
1. Go to Settings > Team > Members
2. Click the current Owner's role
3. Select "Transfer Ownership" and choose new Owner
4. Confirm via email verification

---

## 6. Billing & Account

### Managing Your Subscription
- Go to **Settings > Billing**
- View current plan, next billing date, and invoice history
- Upgrade or downgrade at any time
- Upgrades take effect immediately (prorated)
- Downgrades take effect at next billing cycle

### Payment Methods
- Credit/debit cards (Visa, Mastercard, Amex)
- PayPal
- Bank transfer (Enterprise only)
- All payments processed securely via Stripe

### Invoices
- Invoices generated monthly (or annually)
- Download from Settings > Billing > Invoices
- Includes VAT/tax where applicable

### Cancellation
- Go to Settings > Billing > "Cancel Subscription"
- Your data is retained for 30 days after cancellation
- After 30 days, data is permanently deleted
- You can reactivate within 30 days to restore everything
- **Note:** Cancellation and refund requests must be handled by a human agent.

### Refund Policy
- 14-day money-back guarantee on first subscription
- Pro-rated refunds considered on case-by-case basis
- **Note:** Refund processing must be handled by a human agent. The AI agent cannot process refunds.

---

## 7. Reporting & Dashboards

> Available on **Pro** and **Enterprise** plans

### Available Reports
| Report              | Description                                  |
|---------------------|----------------------------------------------|
| Burndown Chart      | Track remaining work vs. time                |
| Team Velocity       | Cards completed per sprint/week              |
| Workload View       | Cards assigned per team member               |
| Cycle Time          | Average time a card takes from start to done |
| Label Distribution  | Breakdown of cards by label                  |
| Overdue Report      | All cards past their due date                |

### Exporting Data
- Export board as CSV or JSON
- Export reports as PDF
- Available on Pro+ plans
- Go to Board Menu > Export

### Scheduled Reports (Enterprise)
- Auto-send weekly/monthly reports via email
- Configure in Settings > Reports > Scheduled

---

## 8. API & Webhooks

### REST API
- **Base URL:** `https://api.kanbix.io/v1`
- **Authentication:** Bearer token (generate at Settings > API > Create Token)
- **Rate Limit:** 100 requests/minute (Pro), 500/minute (Enterprise)
- **Available on:** Pro and Enterprise plans

### Key Endpoints
| Method | Endpoint                  | Description          |
|--------|---------------------------|----------------------|
| GET    | /boards                   | List all boards      |
| POST   | /boards                   | Create a board       |
| GET    | /boards/{id}/cards        | List cards on board  |
| POST   | /boards/{id}/cards        | Create a card        |
| PATCH  | /cards/{id}               | Update a card        |
| DELETE | /cards/{id}               | Delete a card        |
| GET    | /users/me                 | Get current user     |

### API Documentation
- Full docs at **docs.kanbix.io/api**
- Interactive Swagger UI at **api.kanbix.io/docs**

---

## 9. Troubleshooting

### Common Issues

**Q: I can't see a board that was shared with me.**
A: Check your email for the board invitation and click "Accept." If you've already accepted, try logging out and back in. Ensure you're using the same email the invite was sent to.

**Q: My automation isn't firing.**
A: Verify: (1) The trigger conditions match exactly (list names are case-sensitive), (2) You haven't hit your automation limit, (3) The integration (e.g., Slack) is still connected. Go to Settings > Integrations to check.

**Q: Cards are not syncing across devices.**
A: Kanbix requires an internet connection for real-time sync. Check your connection. If the issue persists, force-refresh your browser (Ctrl+Shift+R) or restart the mobile app.

**Q: I accidentally deleted a card.**
A: Deleted cards go to the board's Trash. Go to Board Menu > Trash > find the card > "Restore." Trash is emptied automatically after 30 days.

**Q: File upload is failing.**
A: Check: (1) File size is under 25MB, (2) You haven't exceeded storage (Free = 100MB, Starter = 5GB, Pro = 50GB), (3) File type is supported (all common formats accepted).

**Q: I can't remove a team member.**
A: Only Admins and Owners can remove team members. Go to Settings > Team > click the member > "Remove from team." The member's cards will remain but become unassigned.

**Q: The mobile app is crashing.**
A: Ensure you're on the latest version (App Store / Google Play). Try: (1) Force-quit and reopen, (2) Clear app cache, (3) Reinstall. If still crashing, contact support with your device model and OS version.

**Q: How do I reset my password?**
A: Go to kanbix.io/login > "Forgot Password" > enter your email > check inbox for reset link. Link expires in 1 hour. If you don't receive it, check spam folder.

**Q: Two-factor authentication (2FA) setup.**
A: Go to Settings > Security > "Enable 2FA." Scan the QR code with an authenticator app (Google Authenticator, Authy). Save backup codes in a safe place. 2FA is required for all Enterprise accounts.

**Q: Can I recover a deleted board?**
A: Deleted boards can be restored within 7 days. Go to Dashboard > "Recently Deleted" > select board > "Restore." After 7 days, the board and all its data are permanently deleted.

**Q: How do I change my email address?**
A: Go to Settings > Profile > "Change Email." You'll receive a verification email at your new address. Click the link to confirm. Your old email will no longer work for login.

---

## 10. Mobile App

### Supported Platforms
- **iOS:** iPhone and iPad (iOS 15+)
- **Android:** Android 10+

### Mobile Features
- View and manage all boards
- Create and edit cards
- Drag cards between lists
- Receive push notifications
- Upload photos from camera as attachments
- Offline mode: view cached boards (sync when reconnected)

### Known Limitations (Mobile)
- Workflow automations can only be viewed, not created/edited
- Reporting dashboards not available (use web app)
- Guest access management not available
- Webhooks/API settings not accessible

---

## 11. Data & Security

### Data Storage
- All data hosted on AWS (US-East-1 by default, EU-West-1 for EU customers)
- Daily encrypted backups with 30-day retention
- 99.9% uptime SLA (Enterprise)

### Security Features
- SSL/TLS encryption in transit
- AES-256 encryption at rest
- SOC 2 Type II compliant
- Two-factor authentication (2FA)
- SSO via SAML 2.0 (Enterprise)
- Audit logs (Enterprise)

### Data Export & Deletion
- Export all your data: Settings > Account > "Export Data" (JSON format)
- Request full account deletion: Settings > Account > "Delete Account"
- GDPR data requests: contact privacy@kanbix.io
- **Note:** Data export and deletion requests should be escalated to a human agent for verification.
