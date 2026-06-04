# CMS Hospital Typology
 
A reproducible data pipeline that clusters U.S. acute-care hospitals into structurally homogeneous peer groups, enabling performance measurement that is adjusted for the conditions under which each hospital actually operates.

## The problem this project addresses
 
CMS publishes quality and efficiency metrics for thousands of hospitals across the United States. These metrics are accurate. They are well-constructed. And when placed side by side without structural context, they produce comparisons that are, in practice, misleading.
A readmission rate does not carry the same meaning at a 24-bed rural hospital and at a 600-bed academic medical center.
The difference is not a matter of one performing better than the other.
It is a matter of the two institutions being structurally different organisms, operating under different constraints, serving different patient populations, with different resources, in different geographic and economic contexts. Placing them on the same ranking treats them as equivalent when they are not.

## What this project does
 
The pipeline assigns each of 3,115 U.S. acute-care hospitals to a structural peer group, defined by seven variables: bed count, case mix index, teaching status, safety-net burden, and urbanicity. These variables describe what a hospital is, not how well it performs. Clustering is performed on these structural features alone, using KMeans with k=7, selected via elbow analysis and validated for domain interpretability.
 
Once cluster assignments are established, performance metrics (readmission rates, infection ratios, patient satisfaction scores, Medicare spending efficiency, and unplanned visit rates) are scored within each cluster, not across the full national distribution. A hospital's performance score reflects how it compares to structurally similar peers, not to the entire country.

The result is a measurement framework that separates two questions that are routinely conflated:
 
1. What kind of hospital is this, given its structural characteristics?
2. How well is this hospital performing, given what it is?
Only by answering the first question can the second be answered meaningfully.

<img width="973" height="554" alt="image" src="https://github.com/user-attachments/assets/996a24e2-8a90-4e79-9409-684590f3c2a1" />


## Why structural context determines what is measurable and what is possible
 
Hospital structure is not a background variable. It is the primary constraint on what outcomes are achievable and what interventions are applicable.
If the data does not account for structural context, the allocation decisions will be systematically skewed. Resources directed at rural hospitals based on their apparent underperformance relative to urban benchmarks may be misallocated, because the interventions appropriate for one type are counterproductive or irrelevant for another.
 
The typology does not prescribe interventions. It establishes the prerequisite: a classification of hospitals by structural type, so that performance evaluation and resource decisions are made within the correct reference frame.

<img width="992" height="556" alt="image" src="https://github.com/user-attachments/assets/4e920d08-9ce8-44bd-8d1b-b9e7e9dc4470" />


## Architecture
 
The pipeline follows a medallion architecture: five layers, each with a single responsibility, each fully reproducible from the previous one.
| Layer | Purpose | Output |
|---|---|---|
| 1 , Raw | Snapshot-dated pulls from the CMS Provider Data API | data/raw/*.csv |
| 2 , Staging | Programmatic standardization, no analytical decisions | SQLite stg_* tables |
| 3 , Cleaned | Cohort definition, structural variable derivation, analytical cleaning | SQLite clean_* tables |
| 4 , Modeled | KMeans cluster assignment, within-cluster performance scoring | SQLite model_* tables |
| 5 , Output | Power BI-ready aggregates and summary CSVs | agg_output/*.csv |
 
When CMS publishes a new data release, only the affected layer needs to be rebuilt. All downstream layers regenerate from it. Every analytical decision is documented in the SQL script that implements it, and is reversible by editing that single script.

## Data sources
 
**CMS Provider Data API** (7 datasets): hospital general information, readmissions and deaths, Medicare spending per beneficiary, healthcare-associated infections, HCAHPS patient survey, unplanned visits, timely and effective care.
 
**CMS IPPS Impact File FY2026**: bed counts, case mix index, teaching status, disproportionate share hospital burden, and urban/rural classification for approximately 3,103 IPPS-paid acute-care hospitals.
 
**USDA ERS Rural-Urban Commuting Area (RUCA) codes, 2020 edition**: ZIP-code-level urbanicity on a 10-level scale, collapsed to four buckets (metro, micro, small town, rural) following standard rural health research methodology.

## Cohort
 
Of 5,432 hospitals in the CMS universe, 3,115 acute-care hospitals are in scope for the typology. 
Critical Access Hospitals, psychiatric specialty facilities, VA facilities, pediatric specialty hospitals, Rural Emergency Hospitals, Department of Defense facilities, and Long-Term Care Hospitals are excluded. Each excluded hospital carries a documented exclusion reason in the pipeline.

## Cluster structure
 
Seven clusters were identified. Each is interpretable as a distinct structural type:
 
| Cluster | n | Interpreted type |
|---|---|---|
| 0 | 850 | Large urban non-teaching |
| 1 | 565 | Urban teaching |
| 2 | 147 | Small community |
| 3 | 971 | Urban safety-net teaching |
| 4 | 123 | Rural non-teaching |
| 5 | 258 | Urban safety-net |
| 6 | 142 | Micro non-teaching |

## Conclusion 

The CMS data is a public resource of substantial analytical value. 
The metrics it contains are carefully constructed and consistently applied. 
The gap this project addresses is not in the data itself, but in the frame used to interpret it.
A hospital's performance, measured without reference to what that hospital structurally is, tells an incomplete story. 
The number exists. 
The context that makes it meaningful does not appear automatically alongside it. 
Building that context is a technical and methodological task. 

The CMS Hospital Typology pipeline is an attempt to do that work rigorously, reproducibly, and in a form that can be updated as the data changes.
The core argument is straightforward: before asking how well a hospital performs, establish what kind of hospital it is. 
That sequence is not optional. 
It is the condition under which the performance question becomes answerable.

<img width="992" height="556" alt="image" src="https://github.com/user-attachments/assets/5564ad4b-486e-41ae-ae67-991f9e49071c" />





 
