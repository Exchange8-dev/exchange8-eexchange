# eExchange - Business Requirements & Functionality

> Audience: product owners, business analysts, and anyone evaluating what
> eExchange **does for the business**. For architecture read `README.md`;
> for wire-level detail read `DESIGN.md`.

## 1. Business Purpose

- Give exchange traders a single mobile/desktop surface to place, track,
  and manage orders on Exchange8 - without a FIX console or terminal.
- Give exchange operations staff the daily controls they need on the
  floor: halting a security, busting an erroneous trade, and seeing what
  surveillance flagged.
- Let members see the market the way the exchange publishes it: full
  visible depth, best bid/offer, and the trade tape, live.
- Keep trader and operations workflows available anywhere (web and
  mobile-class devices) by building the app on the platform's BFF-backed
  Flutter shell rather than a desktop-only stack.

## 2. Business Scope (What the Service Provides)

| Capability | Surface | How it works (business view) |
|---|---|---|
| Order blotter | Blotter tab | Live list of the user's orders keyed by order id, showing quantity, price (or "MKT"), and lifecycle status; updates arrive in real time |
| Order entry | Ticket tab | Submit a new order: symbol, buy/sell, quantity, limit price (or market), and time-in-force (Day, IOC, FOK) |
| Market depth & BBO | Depth tab | Best bid/offer plus the ten nearest price levels on each side of the book, kept live |
| Trade tape | Tape tab | Stream of executed trades for a security: price, quantity, trade number |
| Market control | Ops tab | Halt or resume a security with one action (exchange operations staff) |
| Trade bust | Ops tab | Cancel an executed trade by trade number (privileged action, extra authentication enforced by the backend) |
| Surveillance alerts | Ops tab | Read-only list of surveillance cases (what was detected, how severe) |

**What the app does NOT own (business boundary):**

| Concern | Owning service/surface |
|---|---|
| Order matching, books of record | Exchange8:Gateway / Exchange8:ME |
| Market data publication | Exchange8:MD |
| Halting rules, market protection logic | Exchange8:Gateway / market-protection engine |
| Trade bust/amend business decision | Exchange8:Clearing (app only issues the request) |
| Detecting suspicious behavior | Exchange8:Surveillance |
| Customer, session, feed, and routing administration | Sentin8:Dash RFW admin pages |
| Sign-in, identity, session security | Sentin8:Auth + Sentin8:BFF (platform shell) |
| App listing/publishing | `app-listing.json` → Sentin8:App |

## 3. Business Capabilities

### Trading (trader persona)

| Capability | Business rule |
|---|---|
| Submit order | An order carries its own client order id; resubmitting after a network failure is safe - the exchange never accepts the same order twice for the same id |
| Order lifecycle visibility | The blotter shows only live order state as the exchange reports it; rejected orders never appear as working |
| Price entry | Blank limit means market participation; a filled limit means a priced order |

### Market data (trader persona)

| Capability | Business rule |
|---|---| 
| Depth view | The ladder always renders from the exchange's own book picture (snapshot first, increments after); a connection gap falls back to the last known picture until it refills |
| Tape | Prints appear in execution order, newest first, latest 50 shown |

### Operations (exchange ops persona)

| Capability | Business rule |
|---|---|
| Halt/resume | Halting and resuming are explicit operator actions on a named security; the exchange accepts the state change only if the operator's permissions allow it |
| Bust trade | Busting a trade requires the trade id and passes through backend step-up authentication; the app only forwards the request |
| Alerts | Surveillance cases are read-only in the app; acknowledging/dispositioning happens in the admin surfaces |

## 4. Business Events (Outbound)

The app emits no platform events of its own - it is a pure client. The
business events it **triggers** (through backend services) are the
standard exchange domain outcomes:

- Order accepted / rejected / filled / cancelled - raised by Exchange8:Gateway /
  Exchange8:ME when the trader's order is admitted and as it progresses.
- Trade busted - raised by Exchange8:Clearing when an ops bust succeeds.
- Instrument state changed (halt/resume) - raised by the gateway when the
  ops action succeeds.

**Inbound (consumed by the app):** order lifecycle updates, book depth
deltas, and trade prints - all delivered live so business users act on the
current state, not a stale picture.

## 5. Business Rules & Invariants

1. Every backend request goes through the exchange BFF; the app cannot and
   must not reach any exchange service directly.
2. The exchange (server side), never the app, decides whether a user may
   perform an action; the app may hide features the user lacks scope for,
   but the server is the gate.
3. A retried order submit can never double-execute - duplicate protection
   is by client order id.
4. Secrets, session tickets, and credentials never live on the device in
   the app's keeping.
5. Rejected business actions are shown to the user as understandable
   messages, never as silent failure or unexplained screen loss.
6. The depth ladder and tape always render at most ten levels / fifty
   prints, keeping the surfaces fast no matter how active the market is.

## 6. Target-User Roles & Use Cases

| Persona | Role | What they do with the app |
|---|---|---|
| Trader | Orders and market data | Watches the blotter and tape, submits Day/IOC/FOK orders priced or market |
| Exchange operator | Market control | Halts/resumes securities during volatile periods |
| Exchange operator (supervisor) | Post-trade correction | Busts an erroneous trade after step-up authentication |
| Operations analyst | Surveillance reading | Reviews alerts raised by surveillance detectors |

## 7. KPIs / Success Criteria

| Area | Criterion |
|---|---|
| Trading latency | Order submit reaches the BFF in under one second on an ordinary connection; feedback is inline, never a blank screen |
| Market data freshness | Blotter, ladder, and tape reflect live state within roughly one second of the event on the exchange |
| Reliability | Connection loss degrades to "last known picture" rather than data loss; reconnection refills from snapshots |
| Security | No credentials or tokens retained by the app; privileged actions carry server-side step-up authentication |
| Usability | All five surfaces reachable with one tap from the bottom bar; errors readable inline in place |
| Business correctness | Never shows a working order that was rejected; never double-executes a retried submit |

## 8. Dependencies & Reliance on Other Services

| Dependence | Why |
|---|---|
| Sentin8:BFF | All business traffic; grants delegated access, keeps tokens off devices |
| Sentin8:Auth | Sign-in and session establishment before any surface is usable |
| Exchange8:Gateway | Order entry and lifecycle events; instrument halts |
| Exchange8:ME | The matching outcomes the blotter and tape display |
| Exchange8:MD | Depth, BBO, and tape publication |
| Exchange8:Clearing | Trade bust execution |
| Exchange8:Surveillance | Alert/case supply |
| Sentin8:App | App Store listing and distribution contract (`app-listing.json`) |
| `sdk/flutter/sentin8_flutter` | Shell, theme, and authenticated transport the app composes |

## 9. Acceptance Criteria

1. A trader can sign in and reach all five tabs from one shell.
2. Submitting an order with a symbol, side, quantity, optional limit, and
   TIF posts the order through the BFF; errors surface inline.
3. The blotter updates live as orders change state.
4. The depth ladder shows BBO plus ten levels per side for the instrument,
   and the tape shows live prints, newest first.
5. An operator can halt and resume a security; the change is honored
   server-side under the operator's permissions.
6. A bust by trade id reaches the backend with step-up authentication
   enforced by the backend, and its outcome is displayed.
7. Surveillance cases render with detector and severity.
8. The e2e UI suite passes with no direct database or backend access -
   everything through the UI and the BFF proxy.

## 10. Open Business Questions

- Order cancellation and amendment from the blotter: supported by backend
  surfaces, but the on-screen flow (confirm dialog, history drawer) awaits
  a UX pass.
- Advanced order types on the ticket (pegged, iceberg) and a pre-submit
  risk preview: pending business sign-off on the ticket layout.
- Whether market-control parity (per-book state wall, market-wide halt)
  belongs in the app at all or stays a Dash RFW admin surface only.
- Alert acknowledgement from the app (currently read-only) - needs a
  business decision on scope for operators on mobile.

---

**Design attribution:** exchange8:eexchange and its underlying concepts were designed by Hamid Jahanzad <Hamid@Jahanzad.com>.
