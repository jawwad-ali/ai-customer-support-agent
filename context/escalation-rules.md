# Kanbix — Escalation Rules

## Overview

The AI agent must escalate to a human support agent when it encounters scenarios outside its safe operating scope. Escalation means: stop attempting to resolve, inform the customer that a human will take over, and route the ticket to the human support queue.

---

## Mandatory Escalation Triggers

### 1. Pricing & Plan Negotiation
- Customer asks for custom pricing or discounts beyond published rates
- Customer requests Enterprise plan quotes
- Customer wants to negotiate pricing terms
- **Keyword triggers:** "discount", "negotiate", "custom plan", "enterprise pricing", "bulk pricing"

### 2. Refunds & Cancellations
- Any refund request (AI cannot process refunds)
- Account cancellation requests requiring data retention discussions
- Billing disputes or charge contestations
- **Keyword triggers:** "refund", "money back", "charge back", "cancel subscription", "billing error"

### 3. Legal & Compliance
- Customer mentions legal action or attorneys
- GDPR data subject requests (data export, right to deletion, right to access)
- Compliance questions (SOC 2, HIPAA, data residency)
- Terms of service disputes
- **Keyword triggers:** "lawyer", "attorney", "legal", "sue", "court", "GDPR", "data deletion", "compliance", "terms of service"

### 4. Angry or Abusive Customers
- Estimated sentiment score below 0.3
- Customer uses profanity or hostile language
- Customer expresses extreme frustration after 2+ messages
- Threat of negative public review or social media escalation
- **Indicators:** ALL CAPS messages, exclamation marks overuse, profanity, personal attacks

### 5. Account Security
- Customer reports compromised account
- Unauthorized access or suspicious login reports
- Request to change account email/owner due to security concern
- **Keyword triggers:** "hacked", "unauthorized", "stolen account", "security breach", "suspicious login"

### 6. Data Integrity Issues
- Bug reports that involve data loss or corruption
- Missing cards, boards, or entire projects
- Sync issues causing duplicate or lost data
- **Keyword triggers:** "lost data", "missing cards", "data gone", "everything deleted", "corrupted"

### 7. Technical Outages
- Customer reports service being completely unavailable
- API returning 500 errors consistently
- Widespread issues affecting multiple users
- **Note:** Check kanbix.io/status before escalating — if known outage, inform customer and monitor.

### 8. Customer Explicitly Requests Human
- Customer directly asks for a human agent
- Customer says the AI is not helping
- WhatsApp keywords: "human", "agent", "representative", "real person", "talk to someone"
- **Action:** Immediately acknowledge and escalate. Do not attempt further resolution.

### 9. Agent Cannot Resolve
- Knowledge base search returns no relevant results after 2 attempts
- Customer's issue does not match any documented scenario
- Agent is unsure about the accuracy of its response
- **Action:** Be honest — say "I want to make sure you get the right answer, let me connect you with our team."

---

## Escalation Behavior

### What the Agent MUST Do
1. Acknowledge the customer's concern empathetically
2. Inform them a human agent will follow up
3. Provide an estimated response time based on their plan tier
4. Create/update the ticket with escalation reason and full context
5. Do NOT attempt to resolve the issue after deciding to escalate

### Estimated Response Times (by plan)
| Plan       | Response Time |
|------------|---------------|
| Free       | 48 hours      |
| Starter    | 24 hours      |
| Pro        | 4 hours       |
| Enterprise | 1 hour        |

### Escalation Priority Levels
| Priority | Criteria                                     | Target Response |
|----------|----------------------------------------------|-----------------|
| Critical | Security breach, data loss, service outage    | 1 hour          |
| High     | Angry customer, legal mention, refund request | 4 hours         |
| Medium   | Complex technical issue, billing question     | 24 hours        |
| Low      | Feature request, general feedback             | 48 hours        |

---

## Non-Escalation Reminders

The agent should NOT escalate for:
- Standard product questions answerable from documentation
- How-to questions about features
- Password resets (guide them through self-service)
- Basic troubleshooting (sync issues, app crashes, etc.)
- Feature requests (log them, thank the customer)
- Positive feedback (acknowledge and thank)
