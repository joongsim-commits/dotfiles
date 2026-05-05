# Review Dimensions

Dimensions to probe during adversarial review. Use these as a checklist during initial analysis to identify gaps. Not every dimension applies to every design — skip what's irrelevant.

## Table of Contents

- [Software Architecture](#software-architecture)
- [AI/ML Design](#aiml-design)

---

## Software Architecture

### Component Boundaries
- Are responsibilities clearly separated between components?
- Could any component be split further, or are some unnecessarily granular?
- Where are the coupling points? What happens if one component changes its interface?

### Data Flow
- How does data move through the system end-to-end?
- Where are the transformation points? Are they explicit or hidden?
- What's the source of truth for each piece of data?
- Are there circular dependencies in the data flow?

### API Contracts
- Are interfaces between components explicitly defined?
- How are breaking changes handled? Is there a versioning strategy?
- What happens when a consumer sends unexpected input?

### Scalability
- What's the expected load? What's the growth trajectory?
- Which component becomes the bottleneck first?
- Is scaling horizontal, vertical, or both? What are the limits of each?
- How does the system behave under 10x the expected load?

### Failure Modes
- What happens when each component fails?
- Are there single points of failure?
- What's the retry strategy? Is there backpressure?
- How does the system recover after an outage? Is recovery automatic or manual?
- What data is lost during a failure?

### Coupling & Dependencies
- What external services does the system depend on?
- What happens when an external dependency is unavailable?
- Are there fallback strategies?
- How are dependency versions managed?

### Technology Choices
- Why was each technology chosen over alternatives?
- What are the operational costs (hosting, licensing, expertise)?
- Is the team experienced with these technologies?
- What's the migration path if a technology choice doesn't work out?

### Security
- How is authentication and authorization handled?
- Where is sensitive data stored and how is it encrypted?
- What's the attack surface? What are the most likely attack vectors?
- How are secrets managed?

### Observability
- How do you know the system is healthy?
- What metrics are collected? What alerts exist?
- How do you debug a production issue? What's the logging strategy?
- Is there distributed tracing?

---

## AI/ML Design

### Problem Framing
- Is this actually an ML problem, or could a simpler approach work?
- What's the business metric this model optimizes for?
- How is success measured? What's the minimum acceptable performance?

### Data Pipeline
- Where does training data come from? How is it collected?
- What's the data quality? How are missing values, outliers, and noise handled?
- Is there a data versioning strategy?
- How is training/validation/test split done? Is there data leakage risk?
- What's the data freshness requirement?

### Feature Engineering
- Which features are used? Why these and not others?
- Are there features that could introduce bias?
- How are features computed at serving time? Is there training/serving skew?
- What's the feature store strategy (if any)?

### Model Selection
- Why this model architecture over alternatives?
- What's the complexity/interpretability trade-off?
- Has a simpler baseline been established?
- What are the model's known failure modes?

### Training & Evaluation
- What's the training infrastructure? How long does a training run take?
- What evaluation metrics are used? Do they align with business metrics?
- How is overfitting detected and prevented?
- Is there a reproducibility strategy (seeds, versioned data, versioned code)?

### Serving & Inference
- What's the latency requirement? What's the throughput requirement?
- Is inference batch or real-time? Why?
- How is the model deployed? What's the rollback strategy?
- How are model artifacts versioned and stored?

### Monitoring & Drift
- How is model performance monitored in production?
- How is data drift detected?
- What triggers retraining? Is it automated or manual?
- How do you detect when the model is making confidently wrong predictions?

### Experiment Tracking
- How are experiments tracked and compared?
- What's the process for promoting an experiment to production?
- How are hyperparameters managed?

### Ethics & Fairness
- What biases could exist in the training data?
- How is fairness measured across different user groups?
- What's the impact of a wrong prediction? Who is harmed?
- Is there a human-in-the-loop for high-stakes decisions?
