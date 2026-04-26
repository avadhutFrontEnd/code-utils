# Settings & Subscription Plan - Complete Flow Documentation

## Overview

**Settings Page** (`/create/settings`) and **Subscription Plan Page** (`/create/pricing`) manage user account information, credit balance, subscription management, and payment processing. This documentation covers the complete user flow from viewing settings, managing credits, requesting free credits, to purchasing credits and subscriptions.

**Routes:**
- `/create/settings` - Account Settings page
- `/create/pricing` - Subscription Plan & Pricing page

**Purpose:** 
- View and manage user account information
- Monitor credit balance
- Request free credits through feedback form
- Purchase credits or subscription plans
- Manage active subscriptions
- View payment history

**Key Features:**
- User information display
- Real-time credit balance
- Credit deduction system
- Free credit request (trial extension)
- Payment processing via Stripe
- Subscription management
- Payment history tracking

---

## 1. Landing on Settings Page (`/create/settings`)

### Navigation to Settings

**Access Points:**
1. **From Sidebar:**
   - Click "Settings" in the left sidebar navigation

2. **Direct URL:**
   - Navigate to: `https://app.pixelplusai.com/create/settings`

3. **From Credit Display:**
   - Click "Buy More Credits" button (redirects to pricing page)

### Initial UI State

When a user first lands on the Settings page, they see:

**Layout:**
- Two-column layout:
  - **Left:** Sidebar navigation (PixelPlus AI menu)
  - **Right:** Main content area with settings sections

**Main Content Sections:**

1. **User Information Card:**
   - **Username:** Displayed from user profile
   - **Email Address:** User's email
   - **Account Type:** Badge showing role (SuperAdmin, Admin, Designer, Client)
   - **Account Status:** Badge showing status (Active, Inactive)
   - **Actions:**
     - "Change Password" button (blue, with lock icon)
     - "Access Tokens" button (green)

2. **Credit Balance Card:**
   - **Title:** "Credit Balance"
   - **Current Balance:** Large display showing credit count (e.g., "0 Credits")
   - **Description:** "Available for creating ads and templates"
   - **Actions:**
     - "Buy More Credits" button (blue) - redirects to `/create/pricing`

3. **Current Subscription Card (if subscribed):**
   - **Plan Name:** e.g., "Basic", "Premium", "Pay As You Go"
   - **Status:** Active, Canceled, Past Due
   - **Billing Cycle:** Monthly or Yearly
   - **Amount:** Subscription price
   - **Current Period:** Start and end dates
   - **Actions:**
     - "Change Plan" button (blue)
     - "Cancel Subscription" button (red, if applicable)

4. **Payment History Card:**
   - **Table Display:**
     - Date
     - Plan
     - Amount
     - Status
   - **Pagination:** 5 items per page
   - **Empty State:** "No payment history" message if no payments

---

## 2. Credit System - How It Works

### Credit Overview

**What are Credits?**
- Credits are the currency used to access AI-powered features
- Each feature operation costs a certain number of credits
- Credits are deducted before the operation executes

### Credit Costs by Feature

| Feature | Credit Cost | Endpoint |
|---------|-------------|----------|
| **Ad Maker** (Chatbot) | 1 credit per message | `/chatbot/process-prompt` |
| **Concept Genie** | 1 credit per generation | `/ai/generate-image-with-text` |
| **Compliance Genie** | 5 credits per audit | `/chatbot/validate-brand-guidelines` |
| **Marketing Genie** | 10 credits (first message only) | `/marketing-genie/conversation` |
| **Brand Kit Genie** | 1 credit per message | `/brand-guidelines/conversation` |
| **Prompt Correction** | 1 credit | `/ai/correct-prompt` |

### Credit Deduction Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CREDIT DEDUCTION FLOW                                    │
└─────────────────────────────────────────────────────────────────────────────┘

User Action: Triggers API call (e.g., generate ad, run audit)
  ↓
Frontend: Makes API request
  ↓
Backend: Credit Guard Intercepts Request
  ↓
Step 1: Check User Credits
  - Get user profile from database
  - Extract current credit balance
  - Check if user has unlimited credits (Infinity)
  ↓
Step 2: Determine Credit Cost
  - Based on endpoint/feature
  - Default: 1 credit
  - Special cases:
    * Compliance Genie: 5 credits
    * Marketing Genie: 10 credits (first message only)
  ↓
Step 3: Validate Sufficient Credits
  If currentCredits < creditCost:
    → Throw ForbiddenException
    → Return error:
      {
        success: false,
        message: "Insufficient credits. This operation requires X credits...",
        errorCode: "INSUFFICIENT_CREDITS",
        currentCredits: X,
        requiredCredits: Y
      }
    → Frontend shows error message
    → User redirected to pricing page
  ↓
Step 4: Deduct Credits
  If user has unlimited credits:
    → Skip deduction
    → Allow operation
  Else:
    → newCredits = currentCredits - creditCost
    → Update profile.credit in database
    → Save profile
  ↓
Step 5: Track Credit Usage
  - Log credit usage to database
  - Record: userId, endpoint, creditsDeducted, timestamp
  ↓
Step 6: Check if Credits Exhausted
  If newCredits === 0:
    → Send credit exhausted notification email
    → Set emailSent flag (prevents duplicate emails)
  ↓
Step 7: Allow API Operation
  - Continue with actual API processing
  - Return response with credit info
```

### Credit Balance Display

**Real-Time Updates:**
- Credits displayed on Settings page
- Credits shown in sidebar
- Credits updated after each operation
- API: `GET /api/v1/stripe/user/credits`

**Credit Display States:**
- **Unlimited:** Shows "Unlimited" (for Premium plan users)
- **Normal:** Shows number (e.g., "150 Credits")
- **Low:** Shows in yellow/red if ≤ 5 credits
- **Zero:** Shows "0 Credits" in red

---

## 3. What Happens When Credits Run Out

### Credit Exhaustion Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              WHEN CREDITS REACH ZERO - COMPLETE FLOW                        │
└─────────────────────────────────────────────────────────────────────────────┘

Scenario 1: User Tries to Use Feature with 0 Credits
  ↓
Step 1: User Action
  User clicks "Generate" or triggers any credit-requiring feature
  ↓
Step 2: API Call Made
  Frontend sends request to backend
  ↓
Step 3: Credit Guard Checks
  Backend: CreditGuard.canActivate()
  - Gets user profile
  - Checks currentCredits: 0
  - Determines creditCost: 1 (or more)
  ↓
Step 4: Insufficient Credits Detected
  currentCredits (0) < creditCost (1)
  ↓
Step 5: Error Response
  Backend returns:
  {
    success: false,
    message: "Insufficient credits. This operation requires 1 credits. 
              Please purchase more credits to continue using the service.",
    errorCode: "INSUFFICIENT_CREDITS",
    currentCredits: 0,
    requiredCredits: 1,
    endpoint: "/chatbot/process-prompt"
  }
  ↓
Step 6: Frontend Error Handling
  Frontend receives error
  - Shows error toast message
  - Displays: "Insufficient credits" message
  ↓
Step 7: Automatic Redirect (if configured)
  useTrialRestrictions hook detects 0 credits
  - Calls checkCreditsAndRedirect()
  - Redirects user to: /create/pricing
  ↓
Step 8: User Sees Pricing Page
  - Pricing plans displayed
  - Pay-as-you-go credits option
  - Toast message: "You have no credits remaining. Please purchase a plan 
                     or credits to continue using PixelPlus AI."
```

### Credit Exhaustion Notifications

**Email Notification:**
- Sent when credits reach 0
- Only sent once (emailSent flag prevents duplicates)
- Email includes:
  - Credit exhaustion message
  - Link to pricing page
  - Information about plans

**UI Notifications:**
- Error messages on failed API calls
- Toast notifications
- Automatic redirect to pricing page

---

## 4. Free Credit Request Flow (Trial Extension)

### Overview

When users run out of credits during their trial period, they can request free credits by submitting a feedback form. This extends their trial by 14 days and grants 150 additional credits.

### When Free Credit Request is Available

**Eligibility:**
- User is in trial period (initial or extended)
- User has 0 credits remaining
- User hasn't exceeded maximum trial extensions
- Trial hasn't expired (or recently expired)

### Free Credit Request Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FREE CREDIT REQUEST (TRIAL EXTENSION) FLOW                     │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: User Runs Out of Credits
  Credits reach 0 during trial
  ↓
Step 2: Trial Blocking Modal Appears
  Modal Type: TrialBlockingModal
  - Shows: "Access Restricted"
  - Message: "Your trial has expired and you have no credits remaining. 
              Please submit feedback to extend your trial."
  - Green section: "Extend Your Trial"
  - Button: "Start Feedback Form"
  ↓
Step 3: User Clicks "Start Feedback Form"
  Opens: TrialExtensionModal
  ↓
Step 4: Feedback Form Displayed
  Component: UserFeedbackModal
  - Multi-step form (3 steps)
  - Cannot be dismissed (compulsory)
  - All fields required
  ↓
Step 5: User Fills Feedback Form

  Step 1: Ratings
    - Overall experience (1-10 scale)
    - Feature ratings (1-5 scale):
      * Ad Maker
      * Brand Kit Generator
      * Compliance Checker
      * Campaign Workflow
      * ICP and PVP Generator
    - Ad content quality (1-10 scale)
  
  Step 2: Text Responses
    - Which features saved you the most time? (text)
    - What's one feature you wish PixelPlus AI had? (text)
  
  Step 3: Paid Plan Questions
    - Would you consider upgrading to a paid plan? (yes/no/not-sure)
    - Got ideas to make things even better? (text)
    - Recommendation score (1-10 scale)
  ↓
Step 6: User Submits Form
  Frontend: handleFeedbackSubmit()
  - Validates all fields
  - Converts to API format
  - Calls submitFeedback()
  ↓
Step 7: API Call
  POST /api/v1/trial/feedback
  Headers:
    - Authorization: Bearer <token>
    - Content-Type: application/json
  Body:
  {
    trial_registration_id: "uuid",
    questions_answers: [
      {
        question: "How satisfied are you with your overall experience...",
        answer_type: "scale_1_10",
        scale_answer: 8
      },
      // ... more questions
    ],
    overall_satisfaction: 8,
    would_recommend: 9,
    additional_comments: "Combined text responses..."
  }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: TrialManagementService.submitFeedback()
  ↓
  Step 7.1: Validate Request
    - Check trial_registration_id exists
    - Validate user owns the trial
    - Check trial extension eligibility
  ↓
  Step 7.2: Save Feedback
    - Store feedback in database
    - Link to trial registration
  ↓
  Step 7.3: Extend Trial
    - Add 14 days to trial end date
    - Add 150 credits to user account
    - Update trial status
    - Mark as extended trial
  ↓
  Step 7.4: Return Response
    {
      success: true,
      message: "Trial extended successfully",
      trialExtended: true,
      creditsAdded: 150,
      daysAdded: 14
    }
  ↓
Step 8: Frontend Success Handling
  - Shows success message
  - Closes modal
  - Refreshes page (to update trial status)
  - User now has 150 credits
  - Trial extended by 14 days
```

### Feedback Form Structure

**API Request Format:**
```json
{
  "trial_registration_id": "uuid-string",
  "questions_answers": [
    {
      "question": "How satisfied are you with your overall experience using Pixel Plus AI features?",
      "answer_type": "scale_1_10",
      "scale_answer": 8
    },
    {
      "question": "Rate your experience with AdMaker - Create ads using a single prompt",
      "answer_type": "scale_1_5",
      "scale_answer": 4
    },
    {
      "question": "Which features saved you the most time? Why?",
      "answer_type": "text",
      "text_answer": "Ad Maker saved me hours..."
    }
    // ... 12 total questions
  ],
  "overall_satisfaction": 8,
  "would_recommend": 9,
  "additional_comments": "Combined text from all text fields"
}
```

**Required Fields:**
- Overall experience (scale_1_10)
- All 5 feature ratings (scale_1_5 each)
- Ad content quality (scale_1_10)
- Time-saving features (text)
- Feature request (text)
- Paid plan consideration (text)
- Paid plan feedback (text)
- Recommendation score (scale_1_10)

---

## 5. Payment Flow - Buying Credits

### Overview

Users can purchase credits directly without a subscription. The standard package is **180 credits for $19.99**.

### Buying Credits Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BUYING CREDITS - COMPLETE FLOW                           │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: User Navigates to Pricing Page
  Route: /create/pricing
  Or: Clicks "Buy More Credits" from Settings
  ↓
Step 2: Pricing Page Displayed
  - Shows subscription plans (Basic, Premium)
  - Shows "Pay-as-you-go Credits" section
  - Credits package: "180 Credits - $19.99"
  ↓
Step 3: User Clicks "Buy 180 Credits"
  Frontend: handleBuyCredits(180)
  ↓
Step 4: Validation
  - Validates credits amount (180)
  - Validates user metadata
  - Creates payment metadata
  ↓
Step 5: Create Credits Checkout Session
  Frontend: stripeService.createCreditsSession(180, metadata)
  ↓
  API Call: POST /api/v1/stripe/create-credits-session
  Headers:
    - Authorization: Bearer <token>
    - Content-Type: application/json
  Body:
  {
    creditsAmount: 180,
    metadata: {
      userId: "123",
      userEmail: "user@example.com",
      planId: "payAsYouGo",
      sessionType: "credits",
      creditsAmount: "180",
      timestamp: "1234567890"
    }
  }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: StripeController.createCreditsSession()
  ↓
  Step 5.1: Validate Request
    - Check user authentication
    - Validate credits amount (must be positive)
    - Validate metadata
  ↓
  Step 5.2: Create Stripe Checkout Session
    StripeService.createCreditsSession()
    - Mode: "payment" (one-time payment)
    - Line items: 180 credits for $19.99
    - Metadata: userId, creditsAmount, planId
    - Success URL: /create/success?session_id={CHECKOUT_SESSION_ID}
    - Cancel URL: /create/cancel
  ↓
  Step 5.3: Return Checkout URL
    {
      success: true,
      url: "https://checkout.stripe.com/pay/cs_..."
    }
  ↓
Step 6: Redirect to Stripe Checkout
  Frontend: window.location.href = checkoutUrl
  User redirected to Stripe payment page
  ↓
Step 7: User Completes Payment
  - Enters payment details
  - Submits payment
  - Stripe processes payment
  ↓
Step 8: Stripe Webhook Triggered
  Event: checkout.session.completed
  Webhook URL: POST /api/webhooks/stripe
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    WEBHOOK PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: WebhookController.handleCheckoutCompleted()
  ↓
  Step 8.1: Verify Webhook Signature
    - Validates Stripe signature
    - Constructs webhook event
  ↓
  Step 8.2: Extract Session Data
    - session.metadata.userId
    - session.metadata.creditsAmount: "180"
    - session.metadata.planId: "payAsYouGo"
  ↓
  Step 8.3: Create Payment Record
    - Store payment in payment_history table
    - Status: "succeeded"
    - Plan: "payAsYouGo"
    - Amount: $19.99
  ↓
  Step 8.4: Add Credits to User
    SubscriptionService.addCreditsToUser(userId, 180)
    - Get user profile
    - Check if unlimited credits (skip if yes)
    - currentCredits = parseProfileCredits(profile.credit)
    - newCredits = currentCredits + 180
    - Update profile.credit = newCredits.toString()
    - Reset emailSent flag (false)
    - Save profile
  ↓
  Step 8.5: Log Success
    - Log payment success
    - Log credits added
  ↓
Step 9: User Redirected to Success Page
  URL: /create/success?session_id=cs_...
  - Shows success message
  - Displays credits added
  - Option to return to app
  ↓
Step 10: Credits Available
  - User's credit balance updated: +180 credits
  - Credits immediately available
  - User can continue using features
```

### Credits Purchase API Details

**Endpoint:** `POST /api/v1/stripe/create-credits-session`

**Request:**
```json
{
  "creditsAmount": 180,
  "metadata": {
    "userId": "123",
    "userEmail": "user@example.com",
    "planId": "payAsYouGo",
    "sessionType": "credits",
    "creditsAmount": "180",
    "timestamp": "1234567890"
  }
}
```

**Response:**
```json
{
  "success": true,
  "url": "https://checkout.stripe.com/pay/cs_test_..."
}
```

**Stripe Checkout Session:**
- **Mode:** `payment` (one-time)
- **Amount:** $19.99 (for 180 credits)
- **Currency:** USD
- **Metadata:**
  - `userId`: User ID
  - `creditsAmount`: "180"
  - `planId`: "payAsYouGo"
  - `currentCredits`: Current balance before purchase

---

## 6. Subscription Plan Purchase Flow

### Overview

Users can subscribe to monthly or yearly plans (Basic or Premium) which include credits and additional features.

### Available Plans

**Basic Plan:**
- Monthly: $X/month
- Yearly: $Y/year (save 20%)
- Credits: X credits per billing cycle
- Features: Standard features

**Premium Plan:**
- Monthly: $X/month
- Yearly: $Y/year (save 20%)
- Credits: Unlimited
- Features: All features + premium

**Pay As You Go:**
- One-time: $19.99
- Credits: 180 credits (never expire)

### Subscription Purchase Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              SUBSCRIPTION PURCHASE - COMPLETE FLOW                          │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: User Navigates to Pricing Page
  Route: /create/pricing
  ↓
Step 2: User Selects Plan
  - Chooses Basic or Premium
  - Selects Monthly or Yearly billing
  - Clicks "Subscribe Now"
  ↓
Step 3: Frontend Validation
  handleSubscribe(planId, billingCycle)
  - Validates plan exists
  - Validates billing cycle is supported
  - Creates payment metadata
  ↓
Step 4: Create Checkout Session
  Frontend: stripeService.createCheckoutSession(planId, billingCycle, metadata)
  ↓
  API Call: POST /api/v1/stripe/create-checkout-session
  Headers:
    - Authorization: Bearer <token>
    - Content-Type: application/json
  Body:
  {
    planId: "basic",
    billingCycle: "monthly",
    metadata: {
      userId: "123",
      userEmail: "user@example.com",
      planId: "basic",
      billingCycle: "monthly",
      creditsAmount: "500",
      timestamp: "1234567890"
    }
  }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: StripeController.createCheckoutSession()
  ↓
  Step 4.1: Validate Request
    - Check user authentication
    - Validate planId exists
    - Validate billing cycle is supported by plan
    - Get plan details from database
  ↓
  Step 4.2: Get Stripe Price ID
    - Monthly: plan.stripe_monthly_price_id
    - Yearly: plan.stripe_yearly_price_id
  ↓
  Step 4.3: Create Stripe Checkout Session
    StripeService.createCheckoutSession()
    - Mode: "subscription" (recurring payment)
    - Line items: Price ID for selected billing cycle
    - Metadata: userId, planId, billingCycle, creditsAmount
    - Success URL: /create/success?session_id={CHECKOUT_SESSION_ID}
    - Cancel URL: /create/cancel
  ↓
  Step 4.4: Return Checkout URL
    {
      success: true,
      url: "https://checkout.stripe.com/pay/cs_..."
    }
  ↓
Step 5: Redirect to Stripe Checkout
  Frontend: window.location.href = checkoutUrl
  User redirected to Stripe payment page
  ↓
Step 6: User Completes Payment
  - Enters payment details
  - Submits payment
  - Stripe processes payment
  - Creates subscription in Stripe
  ↓
Step 7: Stripe Webhook Triggered
  Event: checkout.session.completed
  Webhook URL: POST /api/webhooks/stripe
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    WEBHOOK PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: WebhookController.handleCheckoutCompleted()
  ↓
  Step 7.1: Verify Webhook Signature
    - Validates Stripe signature
    - Constructs webhook event
  ↓
  Step 7.2: Extract Session Data
    - session.metadata.userId
    - session.metadata.planId: "basic"
    - session.metadata.billingCycle: "monthly"
    - session.metadata.creditsAmount: "500"
    - session.subscription: Stripe subscription ID
    - session.customer: Stripe customer ID
  ↓
  Step 7.3: Get Plan Details
    - Fetch plan from database
    - Get credits_included
    - Get plan name
  ↓
  Step 7.4: Create Payment Record
    - Store payment in payment_history table
    - Status: "succeeded"
    - Plan: planId
    - Amount: subscription amount
  ↓
  Step 7.5: Create Subscription Record
    SubscriptionService.create()
    - user_id: userId
    - plan_id: planId
    - plan_name: plan.name
    - status: "active"
    - billing_cycle: billingCycle
    - stripe_customer_id: session.customer
    - stripe_subscription_id: session.subscription
    - amount: subscription amount
    - current_period_start: now
    - current_period_end: now + (30 days for monthly, 365 for yearly)
    - credits_total: plan.credits_included
    - credits_remaining: plan.credits_included
  ↓
  Step 7.6: Add Credits to User
    If plan.credits_included > 0:
      SubscriptionService.addCreditsToUser(userId, credits_included)
      - Add credits to user profile
      - Update credit balance
    If plan.credits_included === Infinity (Premium):
      - Set profile.credit = "Infinity"
      - User has unlimited credits
  ↓
  Step 7.7: Handle Credit Transition
    If user had previous credits:
      - Preserve existing credits
      - Add new subscription credits
      - Total = existing + new
    If user was on trial:
      - Add trial credits to subscription credits
      - End trial period
  ↓
  Step 7.8: Log Success
    - Log subscription creation
    - Log credits added
    - Log payment success
  ↓
Step 8: User Redirected to Success Page
  URL: /create/success?session_id=cs_...
  - Shows success message
  - Displays subscription details
  - Shows credits added
  - Option to return to app
  ↓
Step 9: Subscription Active
  - Subscription record created
  - Credits added to account
  - User can use features
  - Recurring billing set up
```

### Subscription API Details

**Endpoint:** `POST /api/v1/stripe/create-checkout-session`

**Request:**
```json
{
  "planId": "basic",
  "billingCycle": "monthly",
  "metadata": {
    "userId": "123",
    "userEmail": "user@example.com",
    "planId": "basic",
    "billingCycle": "monthly",
    "creditsAmount": "500",
    "timestamp": "1234567890"
  }
}
```

**Response:**
```json
{
  "success": true,
  "url": "https://checkout.stripe.com/pay/cs_test_..."
}
```

**Stripe Checkout Session:**
- **Mode:** `subscription` (recurring)
- **Price ID:** Monthly or Yearly price ID from plan
- **Metadata:**
  - `userId`: User ID
  - `planId`: Plan identifier
  - `billingCycle`: "monthly" or "yearly"
  - `creditsAmount`: Credits included in plan
  - `currentCredits`: Current balance before subscription

---

## 7. Complete Frontend to Backend Flow - Settings Page

### Loading User Data

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              SETTINGS PAGE - DATA LOADING FLOW                              │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: Component Mounts
  Settings.tsx component loads
  ↓
Step 2: Load User Data
  Frontend: loadUserData()
  ↓
  API Call 1: GET /api/v1/stripe/user/subscription
  Headers:
    - Authorization: Bearer <token>
  ↓
  Backend: Returns subscription data
  Response:
  {
    subscription: {
      plan_id: "basic",
      plan_name: "Basic",
      status: "active",
      billing_cycle: "monthly",
      amount: 29.99,
      currency: "usd",
      current_period_start: "2026-01-01",
      current_period_end: "2026-02-01",
      credits_total: 500,
      credits_remaining: 350
    },
    credits: 350  // Legacy field
  }
  ↓
  API Call 2: GET /api/v1/stripe/user/credits
  Headers:
    - Authorization: Bearer <token>
  ↓
  Backend: Returns current credits
  Response:
  {
    success: true,
    data: {
      currentCredits: 350,
      isUnlimited: false
    }
  }
  ↓
Step 3: Update Frontend State
  - setSubscription(subscriptionData.subscription)
  - setCredits(creditsData.data.currentCredits)
  - setCreditInfo({ isUnlimited, subscription details })
  - setLoading(false)
  ↓
Step 4: Render UI
  - Display user information
  - Display credit balance
  - Display subscription (if exists)
  - Display payment history
```

### Payment History Loading

```
Step 1: Component Mounts or Page Changes
  useEffect(() => loadPaymentHistory(currentPage)
  ↓
  API Call: GET /api/v1/stripe/user/payment-history
  Query Params:
    - page: 1
    - limit: 5
  Headers:
    - Authorization: Bearer <token>
  ↓
  Backend: Returns paginated payment history
  Response:
  {
    success: true,
    data: [
      {
        id: "uuid",
        plan_id: "basic",
        plan_name: "Basic",
        amount: 29.99,
        currency: "usd",
        status: "succeeded",
        created_at: "2026-01-01T00:00:00Z"
      },
      // ... more payments
    ],
    hasNextPage: true,
    currentPage: 1
  }
  ↓
  Frontend: Update State
  - setPaymentHistory(response.data)
  - setHasNextPage(response.hasNextPage)
  - setTotalPages(calculated)
  ↓
  Render: Payment history table with pagination
```

---

## 8. Complete Frontend to Backend Flow - Payment Processing

### Credits Purchase Flow (Detailed)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│         CREDITS PURCHASE - DETAILED FRONTEND TO BACKEND FLOW                │
└─────────────────────────────────────────────────────────────────────────────┘

FRONTEND LAYER
═══════════════════════════════════════════════════════════════════════════════

User Action: Clicks "Buy 180 Credits" on Pricing Page
  ↓
handleBuyCredits(180) called
  ↓
Step 1: Validation
  validateCreditsAmount(180)
  - Checks: amount > 0, amount is number
  ↓
Step 2: Create Payment Metadata
  createPaymentMetadata('payAsYouGo', 'credits', userProfile, {
    creditsAmount: '180'
  })
  Metadata:
  {
    userId: "123",
    userEmail: "user@example.com",
    planId: "payAsYouGo",
    sessionType: "credits",
    creditsAmount: "180",
    timestamp: "1234567890"
  }
  ↓
Step 3: Validate Metadata
  validateUserMetadata(metadata)
  - Checks required fields present
  ↓
Step 4: API Call
  stripeService.createCreditsSession(180, metadata)
  ↓
  POST /api/v1/stripe/create-credits-session
  Headers:
    - Authorization: Bearer <token>
    - Content-Type: application/json
  Body:
  {
    creditsAmount: 180,
    metadata: { ... }
  }
  ↓
═══════════════════════════════════════════════════════════════════════════════
BACKEND LAYER
═══════════════════════════════════════════════════════════════════════════════

Controller: StripeController.createCreditsSession()
  ↓
Step 1: Validate Request
  - Check user authentication (JWT)
  - Validate creditsAmount (must be positive number)
  - Validate metadata structure
  ↓
Step 2: Get User Profile
  - Fetch user from database
  - Get current credits
  ↓
Step 3: Create Stripe Checkout Session
  StripeService.createCreditsSession()
  ↓
  3.1: Calculate Price
    - 180 credits = $19.99
    - Price in cents: 1999
  ↓
  3.2: Create Stripe Session
    stripe.checkout.sessions.create({
      mode: 'payment',  // One-time payment
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: '180 Credits',
            description: 'Pay-as-you-go credits for PixelPlus AI'
          },
          unit_amount: 1999  // $19.99
        },
        quantity: 1
      }],
      metadata: {
        userId: "123",
        creditsAmount: "180",
        planId: "payAsYouGo",
        currentCredits: "0"
      },
      success_url: "https://app.pixelplusai.com/create/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "https://app.pixelplusai.com/create/cancel"
    })
  ↓
  3.3: Return Session URL
    {
      success: true,
      url: "https://checkout.stripe.com/pay/cs_test_..."
    }
  ↓
Step 4: Return Response
  HTTP 200 with checkout URL
  ↓
═══════════════════════════════════════════════════════════════════════════════
FRONTEND LAYER (Redirect)
═══════════════════════════════════════════════════════════════════════════════

Receive Response
  ↓
Check: result.success && result.url
  ↓
Redirect: window.location.href = result.url
  User redirected to Stripe Checkout page
  ↓
═══════════════════════════════════════════════════════════════════════════════
STRIPE CHECKOUT
═══════════════════════════════════════════════════════════════════════════════

User on Stripe Payment Page
  - Sees: "180 Credits - $19.99"
  - Enters payment details
  - Clicks "Pay $19.99"
  ↓
Stripe Processes Payment
  - Validates card
  - Charges card
  - Creates payment intent
  ↓
Payment Succeeded
  - Stripe redirects to success_url
  - Includes session_id in URL
  ↓
═══════════════════════════════════════════════════════════════════════════════
STRIPE WEBHOOK (Async)
═══════════════════════════════════════════════════════════════════════════════

Stripe Sends Webhook
  Event: checkout.session.completed
  POST /api/webhooks/stripe
  Headers:
    - stripe-signature: <signature>
  Body: <Buffer> (raw event data)
  ↓
Backend: WebhookController.handleStripeWebhook()
  ↓
Step 1: Verify Signature
  stripeService.constructWebhookEvent(body, signature)
  - Validates Stripe signature
  - Constructs event object
  ↓
Step 2: Process Event
  switch (event.type):
    case 'checkout.session.completed':
      handleCheckoutCompleted(session)
  ↓
Step 3: Handle Checkout Completed
  handleCheckoutCompleted(session)
  ↓
  3.1: Extract Metadata
    userId = parseInt(session.metadata.userId)
    creditsAmount = parseInt(session.metadata.creditsAmount)
    planId = session.metadata.planId  // "payAsYouGo"
  ↓
  3.2: Create Payment Record
    SubscriptionService.createPaymentRecord({
      user_id: userId,
      stripe_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent,
      amount: session.amount_total / 100,  // $19.99
      currency: session.currency,
      status: 'succeeded',
      plan_id: 'payAsYouGo',
      payment_request_data: { session_metadata: session.metadata },
      payment_response_data: { session }
    })
  ↓
  3.3: Add Credits to User
    SubscriptionService.addCreditsToUser(userId, 180)
    ↓
    Get user profile:
      profile = await profileRepository.findOne({ where: { user: { id: userId } } })
    ↓
    Check if unlimited:
      if (profile.credit === 'Infinity') return;  // Skip
    ↓
    Calculate new credits:
      currentCredits = parseProfileCredits(profile.credit)  // 0
      newCredits = currentCredits + 180  // 180
    ↓
    Update profile:
      profile.credit = newCredits.toString()  // "180"
      profile.emailSent = false  // Reset notification flag
      await profileRepository.save(profile)
  ↓
  3.4: Log Success
    - Log payment success
    - Log credits added
  ↓
Step 4: Return Webhook Response
  HTTP 200: { received: true }
  ↓
═══════════════════════════════════════════════════════════════════════════════
FRONTEND LAYER (Success Page)
═══════════════════════════════════════════════════════════════════════════════

User Redirected to Success Page
  URL: /create/success?session_id=cs_...
  ↓
Success Page Component
  - Retrieves session_id from URL
  - Optionally verifies payment
  - Shows success message
  - Displays: "180 credits added to your account"
  - Button: "Return to App"
  ↓
User Returns to App
  - Credits now available
  - Can use features immediately
```

### Subscription Purchase Flow (Detailed)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│       SUBSCRIPTION PURCHASE - DETAILED FRONTEND TO BACKEND FLOW             │
└─────────────────────────────────────────────────────────────────────────────┘

FRONTEND LAYER
═══════════════════════════════════════════════════════════════════════════════

User Action: Selects "Basic Plan - Monthly" and clicks "Subscribe Now"
  ↓
handleSubscribe('basic', 'monthly') called
  ↓
Step 1: Validation
  - Validate planId exists
  - Validate billingCycle is supported
  - Get plan details
  ↓
Step 2: Create Payment Metadata
  createPaymentMetadata('basic', 'subscription', userProfile, {
    billingCycle: 'monthly'
  })
  Metadata:
  {
    userId: "123",
    userEmail: "user@example.com",
    planId: "basic",
    billingCycle: "monthly",
    creditsAmount: "500",
    timestamp: "1234567890"
  }
  ↓
Step 3: API Call
  stripeService.createCheckoutSession('basic', 'monthly', metadata)
  ↓
  POST /api/v1/stripe/create-checkout-session
  Headers:
    - Authorization: Bearer <token>
    - Content-Type: application/json
  Body:
  {
    planId: "basic",
    billingCycle: "monthly",
    metadata: { ... }
  }
  ↓
═══════════════════════════════════════════════════════════════════════════════
BACKEND LAYER
═══════════════════════════════════════════════════════════════════════════════

Controller: StripeController.createCheckoutSession()
  ↓
Step 1: Validate Request
  - Check user authentication
  - Validate planId exists in database
  - Validate billingCycle is supported by plan
  ↓
Step 2: Get Plan Details
  PlanService.findOne(planId)
  Returns:
  {
    id: "basic",
    name: "Basic",
    monthly_price: 29.99,
    yearly_price: 299.99,
    credits_included: 500,
    stripe_monthly_price_id: "price_...",
    stripe_yearly_price_id: "price_...",
    billing_cycles: ["monthly", "yearly"]
  }
  ↓
Step 3: Get Stripe Price ID
  priceId = billingCycle === 'monthly' 
    ? plan.stripe_monthly_price_id 
    : plan.stripe_yearly_price_id
  ↓
Step 4: Create Stripe Checkout Session
  StripeService.createCheckoutSession()
  ↓
  4.1: Create Stripe Session
    stripe.checkout.sessions.create({
      mode: 'subscription',  // Recurring payment
      payment_method_types: ['card'],
      customer_email: user.email,
      line_items: [{
        price: priceId,  // Stripe price ID
        quantity: 1
      }],
      metadata: {
        userId: "123",
        planId: "basic",
        billingCycle: "monthly",
        currentCredits: "0",
        creditsAmount: "500"
      },
      success_url: "https://app.pixelplusai.com/create/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "https://app.pixelplusai.com/create/cancel"
    })
  ↓
  4.2: Return Session URL
    {
      success: true,
      url: "https://checkout.stripe.com/pay/cs_test_..."
    }
  ↓
Step 5: Return Response
  HTTP 200 with checkout URL
  ↓
═══════════════════════════════════════════════════════════════════════════════
FRONTEND LAYER (Redirect)
═══════════════════════════════════════════════════════════════════════════════

Receive Response
  ↓
Redirect: window.location.href = result.url
  User redirected to Stripe Checkout page
  ↓
═══════════════════════════════════════════════════════════════════════════════
STRIPE CHECKOUT
═══════════════════════════════════════════════════════════════════════════════

User on Stripe Payment Page
  - Sees: "Basic Plan - $29.99/month"
  - Enters payment details
  - Clicks "Subscribe"
  ↓
Stripe Processes Payment
  - Validates card
  - Charges card
  - Creates subscription in Stripe
  - Creates customer in Stripe
  ↓
Payment Succeeded
  - Stripe redirects to success_url
  - Includes session_id in URL
  ↓
═══════════════════════════════════════════════════════════════════════════════
STRIPE WEBHOOK (Async)
═══════════════════════════════════════════════════════════════════════════════

Stripe Sends Webhook
  Event: checkout.session.completed
  POST /api/webhooks/stripe
  ↓
Backend: WebhookController.handleCheckoutCompleted()
  ↓
Step 1: Extract Session Data
    userId = parseInt(session.metadata.userId)
    planId = session.metadata.planId  // "basic"
    billingCycle = session.metadata.billingCycle  // "monthly"
    creditsAmount = parseInt(session.metadata.creditsAmount)  // 500
    subscriptionId = session.subscription  // Stripe subscription ID
    customerId = session.customer  // Stripe customer ID
  ↓
Step 2: Get Plan Details
    plan = await planService.findOne(planId)
    - credits_included: 500
    - plan name: "Basic"
  ↓
Step 3: Create Payment Record
    SubscriptionService.createPaymentRecord({
      user_id: userId,
      stripe_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent,
      amount: session.amount_total / 100,  // $29.99
      currency: session.currency,
      status: 'succeeded',
      plan_id: 'basic',
      billing_cycle: 'monthly',
      payment_request_data: { session_metadata: session.metadata },
      payment_response_data: { session }
    })
  ↓
Step 4: Create Subscription Record
    SubscriptionService.create({
      user_id: userId,
      plan_id: "basic",
      plan_name: "Basic",
      status: "active",
      billing_cycle: "monthly",
      stripe_customer_id: customerId,
      stripe_subscription_id: subscriptionId,
      stripe_price_id: session.line_items?.data[0]?.price?.id,
      amount: session.amount_total / 100,  // $29.99
      start_date: new Date(),
      current_period_start: new Date(),
      current_period_end: new Date(Date.now() + (billingCycle === 'yearly' ? 365 : 30) * 24 * 60 * 60 * 1000),
      credits_total: plan.credits_included,  // 500
      credits_remaining: plan.credits_included  // 500
    })
  ↓
Step 5: Handle Credits Allocation
  If plan.credits_included > 0:
    SubscriptionService.addCreditsToUser(userId, plan.credits_included)
    - Add 500 credits to user profile
    - Update credit balance
  If plan.credits_included === -1 (Premium):
    - Set profile.credit = "Infinity"
    - User has unlimited credits
  ↓
Step 6: Handle Credit Transition
  If user had previous credits:
    - Preserve existing credits
    - Add new subscription credits
    - Total = existing + new
  If user was on trial:
    - Add trial credits to subscription credits
    - End trial period
  ↓
Step 7: Log Success
  - Log subscription creation
  - Log credits allocated
  - Log payment process completed
  ↓
Step 8: Return Webhook Response
  HTTP 200: { received: true }
  ↓
═══════════════════════════════════════════════════════════════════════════════
FRONTEND LAYER (Success Page)
═══════════════════════════════════════════════════════════════════════════════

User Redirected to Success Page
  URL: /create/success?session_id=cs_...
  ↓
Success Page Component
  - Retrieves session_id from URL
  - Optionally verifies payment
  - Shows success message
  - Displays: "Subscription activated! 500 credits added to your account"
  - Button: "Return to App"
  ↓
User Returns to App
  - Subscription active
  - Credits available
  - Can use features immediately
  - Recurring billing set up
```

---

## 9. Recurring Payment Processing

### Monthly/Yearly Subscription Renewal

When a subscription renews (monthly or yearly), Stripe automatically processes the payment and sends a webhook.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              RECURRING PAYMENT - SUBSCRIPTION RENEWAL FLOW                  │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: Billing Period Ends
  Subscription reaches current_period_end date
  ↓
Step 2: Stripe Automatically Charges
  - Stripe charges customer's payment method
  - Creates invoice
  - Processes payment
  ↓
Step 3: Stripe Webhook Triggered
  Event: invoice.payment_succeeded
  Webhook URL: POST /api/webhooks/stripe
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    WEBHOOK PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: WebhookController.handlePaymentSucceeded()
  ↓
  Step 3.1: Extract Invoice Data
    - invoice.subscription: Stripe subscription ID
    - invoice.amount_paid: Payment amount
    - invoice.currency: Currency
    - invoice.id: Invoice ID
  ↓
  Step 3.2: Find Subscription
    SubscriptionService.findByStripeSubscriptionId(subscriptionId)
    - Get subscription from database
  ↓
  Step 3.3: Check if Recurring Payment
    - Compare subscription start time with current time
    - If > 30 minutes old: Recurring payment
    - If < 30 minutes old: Initial payment (already handled)
  ↓
  Step 3.4: Update Subscription Period
    If recurring payment:
      - Update current_period_start: now
      - Update current_period_end: now + (30 days for monthly, 365 for yearly)
      - Refresh credits_remaining to credits_total
      - Update subscription record
  ↓
  Step 3.5: Refresh Credits
    If plan.credits_included > 0:
      - Get current credits
      - Calculate: newCredits = currentCredits + credits_included
      - Update profile.credit
    If plan.credits_included === -1 (Premium):
      - Ensure profile.credit = "Infinity"
  ↓
  Step 3.6: Create Payment Record
    - Store renewal payment in payment_history
    - Status: "succeeded"
    - Plan: subscription.plan_id
    - Amount: invoice.amount_paid / 100
  ↓
  Step 3.7: Log Success
    - Log recurring payment processed
    - Log credits refreshed
```

---

## 10. Subscription Cancellation Flow

### Canceling a Subscription

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              SUBSCRIPTION CANCELLATION - COMPLETE FLOW                      │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: User Clicks "Cancel Subscription"
  Location: Settings page
  Button: "Cancel Subscription" (red button)
  ↓
Step 2: Cancel Modal Opens
  Component: CancelSubscriptionModal
  - Shows subscription details
  - Warning about credit removal
  - Confirmation required
  ↓
Step 3: User Confirms Cancellation
  User clicks "Yes, Cancel Subscription"
  ↓
Step 4: API Call
  Frontend: subscriptionApi.cancelSubscription(subscriptionId)
  ↓
  API Call: POST /api/v1/stripe/cancel-subscription
  Headers:
    - Authorization: Bearer <token>
    - Content-Type: application/json
  Body:
  {
    subscriptionId: "sub_..."
  }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: StripeController.cancelSubscription()
  ↓
  Step 4.1: Cancel in Stripe
    StripeService.cancelSubscription(stripeSubscriptionId)
    - Calls Stripe API to cancel subscription
    - Sets cancel_at_period_end: false (cancel immediately)
    - Or: Sets cancel_at_period_end: true (cancel at period end)
  ↓
  Step 4.2: Cancel in Database
    SubscriptionService.cancelSubscriptionAndRemoveCredits()
    ↓
    4.2.1: Find Subscription
      - Get subscription from database
      - Verify subscription exists
      - Check not already canceled
    ↓
    4.2.2: Calculate Unused Credits
      unusedCredits = subscription.credits_remaining
      - Get current user credits
      - Calculate credits to remove
    ↓
    4.2.3: Remove Credits
      creditsToRemove = Math.min(unusedCredits, currentCredits)
      remainingCredits = currentCredits - creditsToRemove
      - Update profile.credit = remainingCredits.toString()
    ↓
    4.2.4: Update Subscription
      - status: "canceled"
      - canceled_at: now
      - end_date: now
      - credits_remaining: 0
  ↓
  Step 4.3: Return Response
    {
      success: true,
      subscription: updatedSubscription,
      creditsRemoved: creditsToRemove,
      remainingCredits: remainingCredits
    }
  ↓
Step 5: Frontend Success Handling
  - Shows success toast
  - Displays: "Subscription canceled successfully! X credits removed. Y credits remaining."
  - Redirects to pricing page after 2 seconds
  ↓
Step 6: Subscription Canceled
  - Subscription status: "canceled"
  - Credits removed from account
  - User can purchase new plan or credits
```

---

## 11. Change Password Flow

### Password Change Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CHANGE PASSWORD - COMPLETE FLOW                          │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: User Clicks "Change Password"
  Location: Settings page
  Button: "Change Password" (blue, with lock icon)
  ↓
Step 2: Change Password Modal Opens
  Component: ChangePasswordModal
  - Current password field
  - New password field
  - Confirm new password field
  - Validation rules displayed
  ↓
Step 3: User Fills Form
  - Enters current password
  - Enters new password
  - Confirms new password
  ↓
Step 4: Validation
  Frontend validates:
    - Current password not empty
    - New password meets requirements (min length, complexity)
    - New password matches confirmation
  ↓
Step 5: Submit
  User clicks "Change Password" button
  ↓
Step 6: API Call
  Frontend: authService.changePassword(currentPassword, newPassword)
  ↓
  API Call: POST /api/v1/auth/change-password
  Headers:
    - Authorization: Bearer <token>
    - Content-Type: application/json
  Body:
  {
    currentPassword: "oldPassword123",
    newPassword: "newPassword456"
  }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend: AuthController.changePassword()
  ↓
  Step 6.1: Validate Request
    - Check user authentication
    - Validate current password provided
    - Validate new password provided
  ↓
  Step 6.2: Verify Current Password
    - Get user from database
    - Hash current password
    - Compare with stored password hash
    - If mismatch: Return error
  ↓
  Step 6.3: Hash New Password
    - Hash new password using bcrypt
    - Generate salt
    - Create password hash
  ↓
  Step 6.4: Update Password
    - Update user.password_hash in database
    - Save user record
  ↓
  Step 6.5: Return Response
    {
      success: true,
      message: "Password changed successfully"
    }
  ↓
Step 7: Frontend Success Handling
  - Shows success toast: "Password changed successfully"
  - Closes modal
  - User can log in with new password
```

---

## 12. API Endpoints Summary

### Settings & User Data

| Endpoint | Method | Purpose | Response |
|----------|--------|---------|----------|
| `/api/v1/stripe/user/subscription` | GET | Get user subscription | Subscription object |
| `/api/v1/stripe/user/credits` | GET | Get current credits | Credits balance |
| `/api/v1/stripe/user/payment-history` | GET | Get payment history | Paginated payments |
| `/api/v1/auth/change-password` | POST | Change password | Success message |

### Payment Processing

| Endpoint | Method | Purpose | Response |
|----------|--------|---------|----------|
| `/api/v1/stripe/create-checkout-session` | POST | Create subscription checkout | Checkout URL |
| `/api/v1/stripe/create-credits-session` | POST | Create credits checkout | Checkout URL |
| `/api/v1/stripe/cancel-subscription` | POST | Cancel subscription | Cancellation details |

### Trial & Feedback

| Endpoint | Method | Purpose | Response |
|----------|--------|---------|----------|
| `/api/v1/trial/feedback` | POST | Submit feedback & extend trial | Extension details |

### Webhooks

| Endpoint | Method | Purpose | Response |
|----------|--------|---------|----------|
| `/api/webhooks/stripe` | POST | Handle Stripe webhooks | `{ received: true }` |

---

## 13. Credit Transition Scenarios

### Scenario 1: Free Trial → Pay As You Go

**Initial State:**
- User has 150 free trial credits
- Trial active

**Action:**
- User purchases 180 credits for $19.99

**Result:**
- Free credits preserved: 150
- New credits added: 180
- **Total credits: 330**
- Trial ends immediately

### Scenario 2: Free Trial → Basic Plan

**Initial State:**
- User has 50 free trial credits remaining
- Trial active

**Action:**
- User subscribes to Basic Plan (500 credits/month)

**Result:**
- Free credits preserved: 50
- Subscription credits added: 500
- **Total credits: 550**
- Trial ends immediately
- Billing starts

### Scenario 3: Free Trial → Premium Plan

**Initial State:**
- User has 100 free trial credits
- Trial active

**Action:**
- User subscribes to Premium Plan (unlimited credits)

**Result:**
- Free credits preserved as bonus (not used, but tracked)
- **Credits set to: Infinity (unlimited)**
- Trial ends immediately
- Billing starts

### Scenario 4: Pay As You Go → Subscription

**Initial State:**
- User has 120 Pay As You Go credits
- No active subscription

**Action:**
- User subscribes to Basic Plan (500 credits/month)

**Result:**
- Existing credits preserved: 120
- Subscription credits added: 500
- **Total credits: 620**
- Billing starts

### Scenario 5: Subscription Cancellation

**Initial State:**
- User has Basic Plan subscription
- Subscription credits: 500 total, 200 remaining
- User's total credits: 200

**Action:**
- User cancels subscription

**Result:**
- Unused subscription credits removed: 200
- **Remaining credits: 0**
- Subscription status: "canceled"
- User can purchase new plan or credits

---

## 14. Database Schema

### Subscription Table

```sql
CREATE TABLE subscription (
  id UUID PRIMARY KEY,
  user_id INTEGER NOT NULL,
  plan_id VARCHAR(50) NOT NULL,
  plan_name VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL,  -- 'active', 'canceled', 'past_due'
  billing_cycle VARCHAR(20) NOT NULL,  -- 'monthly', 'yearly'
  stripe_customer_id VARCHAR(255),
  stripe_subscription_id VARCHAR(255),
  stripe_price_id VARCHAR(255),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'usd',
  start_date TIMESTAMP NOT NULL,
  current_period_start TIMESTAMP,
  current_period_end TIMESTAMP,
  canceled_at TIMESTAMP,
  end_date TIMESTAMP,
  credits_total INTEGER NOT NULL,
  credits_remaining INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Payment History Table

```sql
CREATE TABLE payment_history (
  id UUID PRIMARY KEY,
  user_id INTEGER NOT NULL,
  plan_id VARCHAR(50),
  plan_name VARCHAR(100),
  stripe_session_id VARCHAR(255),
  stripe_payment_intent_id VARCHAR(255),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'usd',
  status VARCHAR(20) NOT NULL,  -- 'succeeded', 'failed', 'pending'
  billing_cycle VARCHAR(20),  -- 'monthly', 'yearly', NULL for one-time
  payment_request_data JSONB,
  payment_response_data JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Profile Table (Credit Storage)

```sql
CREATE TABLE profile (
  id UUID PRIMARY KEY,
  user_id INTEGER NOT NULL UNIQUE,
  name VARCHAR(255),
  credit VARCHAR(255) DEFAULT '0',  -- Can be number or 'Infinity'
  emailSent BOOLEAN DEFAULT false,  -- Credit exhaustion notification flag
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## 15. Error Handling

### Credit-Related Errors

**Insufficient Credits:**
```json
{
  "success": false,
  "message": "Insufficient credits. This operation requires 1 credits. Please purchase more credits to continue using the service.",
  "errorCode": "INSUFFICIENT_CREDITS",
  "currentCredits": 0,
  "requiredCredits": 1,
  "endpoint": "/chatbot/process-prompt"
}
```

**Frontend Handling:**
- Shows error toast
- Displays error message
- Redirects to pricing page (if configured)

### Payment Errors

**Checkout Session Creation Failed:**
- Error: "Failed to create checkout session"
- User can retry

**Payment Failed:**
- Stripe returns error
- User sees error on Stripe checkout page
- Can retry payment

**Webhook Processing Failed:**
- Backend logs error
- Payment may succeed but credits not added
- Manual intervention may be required

### Subscription Errors

**Plan Not Found:**
- Error: "Plan not found"
- User should refresh and try again

**Billing Cycle Not Supported:**
- Error: "Plan does not support [billingCycle] billing cycle"
- User should select supported cycle

**Subscription Already Exists:**
- Error: "User already has an active subscription"
- User should cancel existing subscription first

---

## 16. User Journey Examples

### Example 1: New User - First Purchase

```
Step 1: User Signs Up
  - Gets 7-day free trial
  - Receives 150 free credits
  ↓
Step 2: User Uses Credits
  - Uses 150 credits over 5 days
  - Credits reach 0
  ↓
Step 3: User Tries to Generate Ad
  - API call fails
  - Error: "Insufficient credits"
  - Redirected to pricing page
  ↓
Step 4: User Sees Pricing Options
  - Free trial extension (feedback form)
  - Pay As You Go: 180 credits for $19.99
  - Basic Plan: $29.99/month (500 credits)
  - Premium Plan: $99.99/month (unlimited)
  ↓
Step 5: User Chooses Pay As You Go
  - Clicks "Buy 180 Credits"
  - Redirected to Stripe checkout
  - Completes payment
  ↓
Step 6: Payment Processed
  - Webhook adds 180 credits
  - User redirected to success page
  ↓
Step 7: User Returns to App
  - Has 180 credits
  - Can continue using features
```

### Example 2: Trial Extension Request

```
Step 1: User Runs Out of Credits
  - Has 0 credits
  - Trial still active (2 days remaining)
  ↓
Step 2: Trial Blocking Modal Appears
  - Shows: "Access Restricted"
  - Message: "Submit feedback to extend your trial"
  - Button: "Start Feedback Form"
  ↓
Step 3: User Clicks "Start Feedback Form"
  - TrialExtensionModal opens
  - UserFeedbackModal displayed
  ↓
Step 4: User Fills Feedback Form
  - Step 1: Rates overall experience (8/10)
  - Step 1: Rates all features (4-5/5 each)
  - Step 2: Describes time-saving features
  - Step 2: Suggests feature improvements
  - Step 3: Answers paid plan questions
  - Step 3: Provides recommendation score (9/10)
  ↓
Step 5: User Submits Form
  - API call: POST /trial/feedback
  - Backend processes feedback
  - Extends trial by 14 days
  - Adds 150 credits
  ↓
Step 6: Success
  - Modal closes
  - Page refreshes
  - User now has 150 credits
  - Trial extended by 14 days
  - Can continue using features
```

### Example 3: Subscription Upgrade

```
Step 1: User Has Basic Plan
  - Monthly subscription: $29.99
  - 500 credits/month
  - 200 credits remaining
  ↓
Step 2: User Wants More Features
  - Navigates to pricing page
  - Sees Premium Plan: $99.99/month (unlimited credits)
  ↓
Step 3: User Subscribes to Premium
  - Clicks "Subscribe Now" on Premium
  - Selects "Monthly" billing
  - Redirected to Stripe checkout
  - Completes payment
  ↓
Step 4: Webhook Processing
  - Cancels Basic subscription
  - Creates Premium subscription
  - Sets credits to "Infinity"
  - Preserves existing 200 credits (as bonus)
  ↓
Step 5: User Has Premium
  - Unlimited credits
  - All premium features
  - Recurring billing: $99.99/month
```

---

## 17. Key Business Rules

### Credit Rules

1. **Credit Deduction:**
   - Credits deducted before operation executes
   - Deduction is atomic (prevents race conditions)
   - Unlimited credits users skip deduction

2. **Credit Addition:**
   - Credits added immediately after payment
   - Existing credits preserved when upgrading
   - Trial credits added to subscription credits

3. **Credit Expiration:**
   - Subscription credits refresh each billing cycle
   - Pay As You Go credits never expire
   - Trial credits expire with trial period

### Subscription Rules

1. **Active Subscription:**
   - Only one active subscription per user
   - New subscription cancels previous one
   - Credits from canceled subscription removed

2. **Billing Cycles:**
   - Monthly: 30-day periods
   - Yearly: 365-day periods
   - Renewal happens automatically

3. **Cancellation:**
   - Can cancel anytime
   - Unused subscription credits removed
   - Access continues until period end (if cancel_at_period_end: true)
   - Or immediate cancellation (if cancel_at_period_end: false)

### Trial Rules

1. **Trial Extension:**
   - Available once per user (or limited times)
   - Requires feedback form submission
   - Adds 14 days + 150 credits
   - Trial ends when subscription starts

2. **Trial Credits:**
   - 150 credits for initial trial
   - 150 credits for extension
   - Credits expire with trial period

### Payment Rules

1. **Payment Methods:**
   - Credit cards
   - Debit cards
   - Digital wallets (via Stripe)

2. **Payment Processing:**
   - Stripe handles all payments
   - Webhooks process payment completion
   - Credits added after successful payment

3. **Refunds:**
   - Handled through Stripe
   - Credits may be deducted on refund (business logic dependent)

---

## 18. UI Components

### Settings Page Components

1. **Settings.tsx** (Main Component)
   - Manages all settings sections
   - Handles data loading
   - Coordinates modals

2. **ChangePasswordModal.tsx**
   - Password change form
   - Validation
   - API integration

3. **CancelSubscriptionModal.tsx**
   - Subscription cancellation confirmation
   - Warning about credit removal
   - API integration

4. **Pagination.tsx**
   - Payment history pagination
   - Page navigation

### Pricing Page Components

1. **PricingPage.tsx**
   - Main pricing page
   - Plan display
   - Checkout session creation

2. **Pricing.tsx** (Alternative)
   - Alternative pricing component
   - Plan selection
   - Billing cycle toggle

### Trial Components

1. **TrialBlockingModal.tsx**
   - Access restriction modal
   - Shows when credits exhausted
   - Links to feedback form

2. **TrialExtensionModal.tsx**
   - Trial extension wrapper
   - Opens feedback form
   - Handles submission

3. **UserFeedbackModal.tsx**
   - Multi-step feedback form
   - 3 steps with validation
   - Cannot be dismissed

---

## 19. State Management

### Settings Page State

```typescript
const [subscription, setSubscription] = useState<Subscription | null>(null);
const [credits, setCredits] = useState(0);
const [creditInfo, setCreditInfo] = useState<any>(null);
const [paymentHistory, setPaymentHistory] = useState<PaymentHistory[]>([]);
const [loading, setLoading] = useState(true);
const [currentPage, setCurrentPage] = useState(1);
const [hasNextPage, setHasNextPage] = useState(false);
const [totalPages, setTotalPages] = useState(0);
const [showChangePasswordModal, setShowChangePasswordModal] = useState(false);
const [showCancelModal, setShowCancelModal] = useState(false);
```

### Pricing Page State

```typescript
const [plans, setPlans] = useState<Plan[]>([]);
const [loading, setLoading] = useState(true);
const [processing, setProcessing] = useState(false);
const [selectedBillingCycle, setSelectedBillingCycle] = useState<'monthly' | 'yearly'>('monthly');
const [userProfile, setUserProfile] = useState<any>(null);
```

---

## 20. Success and Cancel Pages

### Success Page (`/create/success`)

**URL Parameters:**
- `session_id`: Stripe checkout session ID

**Display:**
- Success message
- Payment details
- Credits added (if applicable)
- Subscription details (if applicable)
- "Return to App" button

**Flow:**
1. Page loads with session_id
2. Optionally verifies payment with backend
3. Displays success message
4. User clicks "Return to App"
5. Redirects to main app

### Cancel Page (`/create/cancel`)

**Display:**
- Cancellation message
- "Return to Pricing" button
- Option to try again

**Flow:**
1. User cancels on Stripe checkout
2. Redirected to cancel page
3. Can return to pricing page
4. Can start checkout again

---

## 21. Security Considerations

### Authentication

- All API endpoints require JWT authentication
- Token validated on every request
- Expired tokens rejected

### Payment Security

- Stripe handles all payment processing
- No credit card data stored in application
- Webhook signature verification
- Secure payment redirects

### Credit Security

- Credit deduction is atomic
- Database transactions ensure consistency
- Race condition prevention
- Credit balance validation

---

## 22. Troubleshooting Common Issues

### Issue: Credits Not Updating After Purchase

**Cause:**
- Webhook not received
- Webhook processing failed
- Payment succeeded but credits not added

**Solution:**
- Check webhook logs
- Verify payment in Stripe dashboard
- Manually add credits if needed
- Check user profile credit field

### Issue: Subscription Not Activating

**Cause:**
- Webhook not received
- Subscription creation failed
- Database error

**Solution:**
- Check webhook logs
- Verify Stripe subscription exists
- Check subscription table
- Retry webhook processing

### Issue: Payment History Not Showing

**Cause:**
- Payment record not created
- Pagination issue
- API error

**Solution:**
- Check payment_history table
- Verify API response
- Check pagination parameters
- Refresh page

### Issue: Cannot Cancel Subscription

**Cause:**
- Subscription not found
- Already canceled
- Stripe API error

**Solution:**
- Verify subscription exists
- Check subscription status
- Check Stripe dashboard
- Retry cancellation

### Issue: Feedback Form Not Submitting

**Cause:**
- Missing required fields
- Validation errors
- API error
- Trial registration ID missing

**Solution:**
- Check all fields filled
- Verify validation rules
- Check API logs
- Verify trial registration exists

---

## 23. Summary

### Key Takeaways

**Settings & Subscription System** provides:

1. **Complete Account Management**
   - User information display
   - Credit balance monitoring
   - Subscription management
   - Payment history tracking

2. **Flexible Credit System**
   - Pay-as-you-go credits
   - Subscription-based credits
   - Unlimited credits (Premium)
   - Credit preservation on upgrades

3. **Trial Extension**
   - Free credit request via feedback
   - 14-day extension
   - 150 additional credits
   - Feedback collection

4. **Secure Payment Processing**
   - Stripe integration
   - Webhook-based processing
   - Automatic credit allocation
   - Recurring billing support

5. **User-Friendly Flow**
   - Clear error messages
   - Automatic redirects
   - Success confirmations
   - Easy cancellation

### User Value

- **Transparency:** Clear credit balance and usage
- **Flexibility:** Multiple payment options
- **Convenience:** Automatic renewals and credit refresh
- **Support:** Trial extension for feedback
- **Control:** Easy subscription management

### Technical Highlights

- **Stripe Integration:** Secure payment processing
- **Webhook System:** Reliable payment confirmation
- **Credit Guards:** Automatic credit management
- **Database Transactions:** Data consistency
- **Real-time Updates:** Live credit balance

---

**End of Documentation**