import Foundation
import SwiftUI

enum DataCloud360StudyBank {
    static let sections: [StudySection] = [
        StudySection(
            id: "section-1",
            title: "Data Cloud Overview",
            color: Color(red: 0.0, green: 0.55, blue: 0.55),
            lightColor: Color(red: 0.0, green: 0.55, blue: 0.55).opacity(0.12),
            icon: "cloud.fill",
            objectives: [
                StudyObjective(
                    id: "topic-1.1",
                    title: "Identify Typical Use Cases for Data Cloud",
                    topics: [
                        StudyTopic(
                            id: "topic-1.1-q1",
                            number: 1,
                            question: "What is the difference between a B2C and B2B identity resolution use case?",
                            answer: "B2C resolves individual consumer profiles using the Individual DMO, matching on personal contact points like email and phone. B2B resolves Account records and their associated contacts using the Unified Account DMO, matching on company identifiers like DUNS numbers and domains in addition to individual contact data."
                        ),
                        StudyTopic(
                            id: "topic-1.1-q2",
                            number: 2,
                            question: "How do B2C and B2B data models differ in identity resolution?",
                            answer: "B2C uses the Individual DMO as the root entity, with Contact Point objects linked to it. B2B uses the Account DMO as the root entity, with Contacts linked to Accounts. B2B requires additional DMO mappings for Account objects and handles both account-level and contact-level matching."
                        ),
                        StudyTopic(
                            id: "topic-1.1-q3",
                            number: 3,
                            question: "A healthcare org wants to unify patient data from a portal, call center, and EHR. What Data Cloud capabilities apply?",
                            answer: "Use Data Streams to ingest from each source (Ingestion API for portal events, CRM Connector or cloud storage for call center, MuleSoft or S3 for EHR). Identity Resolution unifies patient records across systems. Calculated Insights compute metrics like visit frequency. Data Actions trigger real-time alerts or case creation. Consent Management enforces HIPAA-aligned data use restrictions."
                        ),
                        StudyTopic(
                            id: "topic-1.1-q4",
                            number: 4,
                            question: "A financial services company wants to reduce churn using real-time identification of at-risk customers. How does Data Cloud support this?",
                            answer: "Ingest behavioral and transactional data via Ingestion API or CRM Connector. Use Streaming Insights to detect real-time churn signals. Build a Calculated Insight for a churn risk score. Create a Segment of at-risk customers filtered by that score. Activate the segment to Marketing Cloud for a retention journey, or use a Data Action to alert a service agent in real time."
                        ),
                        StudyTopic(
                            id: "topic-1.1-q5",
                            number: 5,
                            question: "A retailer wants personalized next-best-offer recommendations from unified purchase, browsing, and service data. Which capabilities enable this?",
                            answer: "Ingest purchase history (Commerce Cloud or S3), browsing events (Ingestion API), and service history (CRM Connector). Run Identity Resolution to unify the customer across all sources. Build Calculated Insights for lifetime value, product affinity, and RFM scores. Use Einstein Model Builder or BYOM for predictions. Activate personalized segments to Marketing Cloud or Commerce Cloud."
                        ),
                        StudyTopic(
                            id: "topic-1.1-q6",
                            number: 6,
                            question: "A company wants real-time service alerts when a customer matches a high-churn risk pattern. Which feature enables this?",
                            answer: "Streaming Insights combined with Data Actions. A Streaming Insight monitors incoming event data using a window function. When a threshold is crossed, a Data Action fires and sends an event to a Salesforce Flow or webhook, which creates a Service Cloud case or sends an alert."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-1.2",
                    title: "Articulate How Data Cloud Works and Its Dependencies",
                    topics: [
                        StudyTopic(
                            id: "topic-1.2-q1",
                            number: 1,
                            question: "What platform dependencies are required to provision and use Data Cloud?",
                            answer: "A Salesforce org (Enterprise Edition or higher), a Data Cloud license (SKU) billed separately, and the Data Cloud Admin permission set assigned to the provisioning user. Marketing-specific features require a Data Cloud for Marketing license. Connecting to other Salesforce Clouds requires those platforms to be separately licensed."
                        ),
                        StudyTopic(
                            id: "topic-1.2-q2",
                            number: 2,
                            question: "Describe the end-to-end data flow in Data Cloud.",
                            answer: "Source Systems feed into Data Streams, which create Data Source Objects (transient staging) and Data Lake Objects (persistent storage). DLOs are mapped to Data Model Objects through harmonization. Identity Resolution runs on DMOs to produce Unified Individuals or Unified Accounts. Segmentation filters those unified profiles. Activations deliver segment audiences to external targets. Calculated and Streaming Insights feed Data Actions and enrichments."
                        ),
                        StudyTopic(
                            id: "topic-1.2-q3",
                            number: 3,
                            question: "What dependencies exist between Data Streams, DLOs, and DMOs?",
                            answer: "A Data Stream ingests raw data and automatically creates a DSO and a DLO. A DLO must be mapped to a DMO before the data can be used for identity resolution, segmentation, or activation. A DMO inherits its data category from the first DLO mapped to it. You cannot delete a data stream if its DLO attribute is mapped to a DMO, referenced in a Calculated Insight, or associated with a data kit."
                        ),
                        StudyTopic(
                            id: "topic-1.2-q4",
                            number: 4,
                            question: "In what order must Data Streams, DLOs, and DMOs be configured?",
                            answer: "1. Set up connectors in Data Cloud Setup. 2. Create Data Streams to ingest data. 3. Review and configure DLOs. 4. Apply Data Transforms if needed. 5. Map DLOs to DMOs. 6. Configure Identity Resolution rulesets. 7. Build Calculated or Streaming Insights. 8. Create Segments. 9. Configure Activations."
                        ),
                        StudyTopic(
                            id: "topic-1.2-q5",
                            number: 5,
                            question: "What is the role of the Salesforce Connector and which objects are available by default?",
                            answer: "The Salesforce CRM Connector connects a Salesforce org to Data Cloud using a connected app and integration user. Standard objects available by default include Account, Contact, Lead, Case, and Opportunity. Custom objects and fields require the integration user to have Read and View All permissions on those objects and fields."
                        ),
                        StudyTopic(
                            id: "topic-1.2-q6",
                            number: 6,
                            question: "How does Data Cloud interact with external cloud storage?",
                            answer: "Data Cloud uses Cloud Storage Connectors (Amazon S3, Google Cloud Storage, Microsoft Azure Blob Storage) for batch ingestion. Files must be CSV or Parquet format. GZ and ZIP compression are supported for CSV. A schedule determines how often Data Cloud polls the storage location for new files."
                        ),
                        StudyTopic(
                            id: "topic-1.2-q7",
                            number: 7,
                            question: "How does the Data Cloud refresh cycle affect segment membership timing?",
                            answer: "The cycle is Ingestion, Harmonization, Identity Resolution, Segmentation, and Activation. Each step has its own processing time. Segment membership is not updated in real time by default; it depends on the segment publish schedule (12-hour, 24-hour, or continuous). Activation delivery timing also depends on the target platform's own processing latency."
                        ),
                        StudyTopic(
                            id: "topic-1.2-q8",
                            number: 8,
                            question: "Data was ingested via a Data Stream but records do not appear in the Unified Profile. Most likely cause?",
                            answer: "The DLO has not been mapped to a DMO, or the mapping is incomplete. For identity resolution to work, the Individual DMO must be mapped, and either a Contact Point object or a Party Identification object must also be mapped."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-1.3",
                    title: "Describe and Apply the Principles of Data Ethics",
                    topics: [
                        StudyTopic(
                            id: "topic-1.3-q1",
                            number: 1,
                            question: "What are the core principles of data ethics in the context of Data Cloud?",
                            answer: "Transparency (be clear about data collection and use), Consent (obtain explicit informed consent), Data Minimization (collect only what is necessary), Purpose Limitation (use data only for its stated purpose), Accuracy (keep data current), Security (protect from unauthorized access), and Accountability (organizations are responsible for how they handle data)."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q2",
                            number: 2,
                            question: "How do data ethics principles constrain data ingestion and use in Data Cloud?",
                            answer: "Data minimization means only ingesting fields needed for your use cases. Purpose limitation means a data stream built for service use cases should not be repurposed for marketing without re-evaluating consent. Consent means verifying that individuals in a segment have consented to the specific communication channel before activating."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q3",
                            number: 3,
                            question: "How does data minimization apply to configuring Data Streams?",
                            answer: "When setting up a Data Stream, deselect fields that are not needed for your defined use cases. For example, if ingesting Contact records for email marketing, do not ingest salary or medical history fields. This reduces risk and aligns with GDPR and CCPA requirements."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q4",
                            number: 4,
                            question: "What is consent management in Data Cloud?",
                            answer: "The process of capturing, storing, and enforcing customer preferences about how their data can be used. Data Cloud uses the Salesforce Consent Data Model, which includes Global Consent (broadest level), Engagement Channel Consent (per channel like email or SMS), Contact Point Consent (per specific contact point), Data Use Purpose Consent (per business purpose), and Consent by Brand (for multi-brand organizations)."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q5",
                            number: 5,
                            question: "How do the Individual object and consent records affect segmentation and activation?",
                            answer: "The Individual DMO is the central profile object. Consent records are linked to it via Contact Point Consent and Engagement Channel Consent objects. When building a segment or activation, Data Cloud can filter out opted-out individuals. Activation targets can be configured to respect consent flags, excluding opted-out individuals from the audience."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q6",
                            number: 6,
                            question: "Which Data Cloud mechanism enforces opt-out at the platform level?",
                            answer: "Contact Point Consent records. When a Contact Point has an opt-out flag, Data Cloud suppresses that contact point during activation. The Unified Consent Repository aggregates consent preferences from all source systems, ensuring opt-outs captured in any system are honored across all activations."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q7",
                            number: 7,
                            question: "How does an opt-out signal propagate through identity resolution into activations?",
                            answer: "When identity resolution merges source Individual records into a Unified Individual, consent records from contributing sources are also unified. The most restrictive consent signal wins: if any contributing source record has an opt-out for a channel, the Unified Individual is treated as opted out for that channel. Data Cloud then suppresses opted-out contact points during activation."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q8",
                            number: 8,
                            question: "What happens when a Unified Individual has one source with consent and one without?",
                            answer: "Data Cloud applies the most restrictive consent rule. If one contributing source record has an explicit opt-out, the Unified Individual is treated as opted out for that channel, even if another source record has an opt-in."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q9",
                            number: 9,
                            question: "What is the difference between pseudonymization and anonymization?",
                            answer: "Pseudonymization replaces personal data with a pseudonym (e.g., a hashed ID). The original data can be re-identified if the mapping key is available, so it is still considered personal data under GDPR. Anonymization irreversibly alters personal data so the individual can no longer be identified. Truly anonymized data is no longer subject to GDPR."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q10",
                            number: 10,
                            question: "When is pseudonymization versus anonymization appropriate?",
                            answer: "Use pseudonymization when you still need to process or analyze the data but want to reduce risk, such as hashing email addresses before sending to ad platforms. Use anonymization when data is no longer needed for operational purposes and must be retained only for statistical or research purposes, or to fulfill GDPR erasure requests for data retained in aggregate form."
                        ),
                        StudyTopic(
                            id: "topic-1.3-q11",
                            number: 11,
                            question: "A customer submitted a GDPR right-to-erasure request. How does Data Cloud support this?",
                            answer: "Identify all data streams containing the individual's data. Delete the individual's records from each relevant data stream using the delete API or UI-based deletion. Re-run identity resolution to remove the individual from the Unified Profile. The Unified Individual record and all associated link objects are removed. Deleting a ruleset removes all unified customer data, so it is better to delete specific records rather than the entire ruleset."
                        ),
                    ]
                ),
            ]
        ),
        StudySection(
            id: "section-2",
            title: "Data Cloud Setup and Administration",
            color: Color.blue,
            lightColor: Color.blue.opacity(0.12),
            icon: "gearshape.2.fill",
            objectives: [
                StudyObjective(
                    id: "topic-2.1",
                    title: "Apply Data Cloud Permissions, Permission Sets, and Org-Wide Settings",
                    topics: [
                        StudyTopic(
                            id: "topic-2.1-q1",
                            number: 1,
                            question: "What org-wide settings must be configured before Data Cloud can be provisioned?",
                            answer: "My Domain must be enabled and deployed. API access must be enabled. The provisioning user must have the Data Cloud Admin permission set. The org must have a valid Data Cloud license SKU. For Marketing features, the Data Cloud for Marketing license must also be provisioned."
                        ),
                        StudyTopic(
                            id: "topic-2.1-q2",
                            number: 2,
                            question: "What permission sets are available in Data Cloud?",
                            answer: "Data Cloud Admin grants full administrative access. Data Cloud Marketing Admin grants admin access scoped to marketing features. Data Cloud Marketing Manager can build segments and activations but cannot modify data streams. Data Cloud Marketing Specialist can create segments but cannot create or modify activations. Data Cloud Marketing Data Aware Specialist can map data to the data model and create data streams, identity resolution rulesets, and calculated insights. Data Cloud User has basic read access to unified profiles and enrichments."
                        ),
                        StudyTopic(
                            id: "topic-2.1-q3",
                            number: 3,
                            question: "What capabilities does each permission set grant?",
                            answer: "Admin: full configuration of data streams, mappings, identity resolution, CIs, segments, activations, data spaces, and all admin settings. Marketing Admin: manages day-to-day configuration, support, maintenance, and internal system audits. Marketing Manager: manages segmentation strategy, creates activation targets and activations. Marketing Specialist: creates segments only. Data Aware Specialist: maps data to the data model, creates data streams, identity resolution rulesets, and CIs. Data Cloud User: views unified profiles and enrichments."
                        ),
                        StudyTopic(
                            id: "topic-2.1-q4",
                            number: 4,
                            question: "How does the Data Cloud Admin permission set differ from the Salesforce System Administrator profile?",
                            answer: "The Salesforce System Administrator profile grants broad CRM platform access but does not automatically grant Data Cloud-specific capabilities. The Data Cloud Admin permission set must be explicitly assigned to grant access to Data Cloud features like data streams, identity resolution, and segmentation."
                        ),
                        StudyTopic(
                            id: "topic-2.1-q5",
                            number: 5,
                            question: "How do Data Cloud permission sets interact with Salesforce profiles?",
                            answer: "Permission sets grant additive permissions on top of a user's Salesforce profile. However, a Salesforce profile can restrict access if it explicitly denies certain object or field permissions. Best practice is to assign users a minimal base profile and layer Data Cloud permission sets on top."
                        ),
                        StudyTopic(
                            id: "topic-2.1-q6",
                            number: 6,
                            question: "Marketing users need to build segments and run activations but not modify data streams. Which permission set?",
                            answer: "Assign the Data Cloud Marketing Manager permission set. It grants the ability to manage segmentation strategy and create activation targets and activations, but does not grant access to modify data streams or data mappings."
                        ),
                        StudyTopic(
                            id: "topic-2.1-q7",
                            number: 7,
                            question: "How should a third-party integration user access Data Cloud APIs without full admin rights?",
                            answer: "Create a dedicated integration user. Assign the Data Cloud Marketing Data Aware Specialist permission set or a custom permission set with only the required API permissions. Use Connected App OAuth credentials for the integration. Do not assign the Data Cloud Admin permission set."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.2",
                    title: "Describe and Configure Data Stream Types and Data Bundles",
                    topics: [
                        StudyTopic(
                            id: "topic-2.2-q1",
                            number: 1,
                            question: "What data stream types are available in Data Cloud?",
                            answer: "Salesforce CRM Connector (batch, standard and custom Salesforce objects), Marketing Cloud Engagement (batch, MC data extensions and email engagement), B2C Commerce Cloud (batch, orders and shopper data), Marketing Cloud Personalization (near real-time, behavioral events), Omnichannel Inventory (near real-time, inventory changes), Ingestion API Streaming (near real-time, web and mobile events), Ingestion API Bulk (batch, large REST API loads), Cloud Storage such as S3, GCS, and Azure (batch, CSV or Parquet files), MuleSoft Anypoint (batch or near real-time, legacy systems), Amazon Kinesis (near real-time, high-volume AWS event streams), and Google Ads or Meta Ads (batch, ad engagement data)."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q2",
                            number: 2,
                            question: "What are the key differences between data stream types?",
                            answer: "The Salesforce CRM Connector uses a connected app and integration user and supports standard and custom objects. The Ingestion API supports both streaming and bulk patterns and requires a schema definition before data can be sent. Cloud Storage is batch-only using CSV or Parquet files with scheduled polling. Marketing Cloud Engagement requires both Data Cloud and Marketing Cloud to be configured. Marketing Cloud Personalization has no historical lookback on first run, with 15-minute latency for Profile data and 2-minute latency for Events and Engagement data."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q3",
                            number: 3,
                            question: "What is a Data Bundle and how does it accelerate setup?",
                            answer: "A Data Bundle is a pre-packaged set of data stream configurations, DMO mappings, and relationships for common Salesforce Cloud objects. Installing one automatically creates data streams for standard objects, maps the resulting DLOs to the appropriate standard DMOs, and establishes standard DMO relationships, eliminating the need to manually configure mappings for standard Salesforce objects."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q4",
                            number: 4,
                            question: "What are the steps to set up a Salesforce CRM data stream?",
                            answer: "1. Configure the Salesforce CRM Connector in Data Cloud Setup with the org credentials and connected app. 2. Assign the Data Cloud Salesforce Connector permission set to the integration user in the source org with Read and View All on the objects to be ingested. 3. In the Data Streams tab, click New and select the Salesforce CRM Connector. 4. Select the object and fields to ingest. 5. Set the primary key, data category, refresh mode, and schedule. 6. Deploy the data stream."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q5",
                            number: 5,
                            question: "What setup is required for the Marketing Cloud Engagement data stream?",
                            answer: "In Marketing Cloud, create a connected app and configure the Data Cloud connector. In Data Cloud Setup, configure the Marketing Cloud Engagement Connector using the connected app credentials. In the Data Streams tab, create a new data stream using the Marketing Cloud Engagement connector and select the data extensions or engagement objects to ingest."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q6",
                            number: 6,
                            question: "What Marketing Cloud data objects are available via the Marketing Cloud Engagement data stream?",
                            answer: "Email engagement data (sends, opens, clicks, bounces, unsubscribes), SMS engagement data, subscriber data from the All Subscribers list, data extensions (custom tables in Marketing Cloud), and journey activity data."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q7",
                            number: 7,
                            question: "When would you choose the Ingestion API over a Cloud Storage connector for near-real-time event data?",
                            answer: "Choose the Ingestion API when data freshness is critical and events must be acted upon in near real time (seconds to minutes). Cloud Storage is batch-only with scheduled polling (typically hourly or daily), making it suitable for nightly exports or large historical loads but not for real-time use cases."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q8",
                            number: 8,
                            question: "What is the difference between Full Refresh and Upsert refresh mode?",
                            answer: "Full Refresh replaces all existing records in the DLO with records from the new file or query. It is limited to datasets of 50 million records or fewer. Upsert inserts new records and updates existing records based on the primary key but does not delete records absent from the source. Use Full Refresh when the source always provides a complete current snapshot. Use Upsert for incremental updates."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q9",
                            number: 9,
                            question: "What is delta refresh mode and when is it preferred?",
                            answer: "Delta refresh ingests only records created or modified since the last successful run, using either a date field (Delta Extract by Date) or a record number (Delta Extract by Number). It is preferred for very large datasets over 50 million records where Full Refresh is not feasible, or when the source can reliably export only changed records to minimize processing time."
                        ),
                        StudyTopic(
                            id: "topic-2.2-q10",
                            number: 10,
                            question: "A company ingests a nightly S3 product catalog that always contains the full current list. Which refresh mode?",
                            answer: "Full Refresh. Since the file always contains the complete current product list, Full Refresh ensures that products removed from the catalog are also removed from the DLO. Upsert would leave deleted products in the DLO because it does not remove records absent from the source file."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.3",
                    title: "Identify Use Cases for Data Spaces and Create Data Spaces Based on Requirements",
                    topics: [
                        StudyTopic(
                            id: "topic-2.3-q1",
                            number: 1,
                            question: "What is a data space and what problem does it solve?",
                            answer: "A data space is a logical partition within a single Data Cloud instance that segregates data, metadata, and processes. It solves the problem of multi-brand, multi-region, or multi-business-unit organizations that need to keep data isolated within a single Data Cloud org."
                        ),
                        StudyTopic(
                            id: "topic-2.3-q2",
                            number: 2,
                            question: "What is the default data space?",
                            answer: "Every Data Cloud org has a default data space. Data streams, DMOs, segments, and activations not explicitly assigned to a non-default data space are placed in the default data space. All users with Data Cloud access can see data in the default data space unless sharing rules restrict access."
                        ),
                        StudyTopic(
                            id: "topic-2.3-q3",
                            number: 3,
                            question: "What objects can be scoped to a data space, and which are shared across all data spaces?",
                            answer: "Data space-aware objects include data shares from BYOL, data graphs, identity resolution rulesets, calculated insights, data actions, segmentation, and activation. Data streams and DLOs are accessible across data spaces but can be associated with a specific data space with or without filters. Connector configurations and some org-wide settings are shared across all data spaces."
                        ),
                        StudyTopic(
                            id: "topic-2.3-q4",
                            number: 4,
                            question: "Can segments in one data space reference DMO data from another data space?",
                            answer: "No. Segments are scoped to a data space and can only reference DMOs within the same data space. If cross-space data access is needed, the data must be duplicated into the target data space or a different architectural approach must be used."
                        ),
                        StudyTopic(
                            id: "topic-2.3-q5",
                            number: 5,
                            question: "A multinational company must ensure EU customer data is only visible to EU-based teams. How should data spaces be configured?",
                            answer: "Configure a dedicated EU data space. Assign all EU-related data streams, DMOs, segments, and activations to this data space. Use Data Cloud Sharing Rules and permission sets to restrict access to the EU data space to only EU-based users."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.4",
                    title: "Manage and Administer Data Cloud",
                    topics: [
                        StudyTopic(
                            id: "topic-2.4-q1",
                            number: 1,
                            question: "What activation error types are surfaced in the Data Cloud UI and what remediation steps apply?",
                            answer: "Authentication errors occur when activation target credentials have expired; re-authenticate the connection. Mapping errors occur when a mapped field no longer exists in the DMO or target schema; review and update field mappings. Schema mismatch errors occur when a field data type does not match what the target expects; correct the mapping or transform the data. Rate limit errors occur when the target API is throttling requests; reduce activation frequency or request higher limits from the target platform."
                        ),
                        StudyTopic(
                            id: "topic-2.4-q2",
                            number: 2,
                            question: "What does a high rejected count in an activation indicate?",
                            answer: "Records in the segment were not accepted by the activation target. Common causes include missing required fields (e.g., subscriber key is null), invalid field values (e.g., invalid email format), duplicate records in the activation payload, or consent suppression where records are excluded due to opt-out flags."
                        ),
                        StudyTopic(
                            id: "topic-2.4-q3",
                            number: 3,
                            question: "After a change to the identity resolution ruleset, a Marketing Cloud Engagement activation now shows all records as rejected. Most likely cause?",
                            answer: "The ruleset change altered the Unified Individual IDs or contact point linkages. When a ruleset is re-run, unified profiles are rebuilt. If the subscriber key mapping to Marketing Cloud is now broken (e.g., the source of the subscriber key changed), all records will be rejected because Marketing Cloud cannot match them to existing subscribers."
                        ),
                        StudyTopic(
                            id: "topic-2.4-q4",
                            number: 4,
                            question: "An activation to an advertising platform shows 0 accepted records despite the segment having 50,000 members. What should be checked first?",
                            answer: "The most likely explanation is that the contact point required by the advertising platform (e.g., hashed email for Google Ads or Meta Ads) is null for all segment members. Check whether the ContactPointEmail DMO is mapped and populated, whether the activation is configured to use the correct contact point type, and whether the advertising platform connection credentials are valid."
                        ),
                        StudyTopic(
                            id: "topic-2.4-q5",
                            number: 5,
                            question: "An activation to Marketing Cloud shows 10,000 accepted records but the MC audience only has 8,500 subscribers. Likely reasons?",
                            answer: "Some records may have contact points that do not match existing Marketing Cloud subscribers (new contacts not yet in MC). Duplicate contact points in the activation payload may have been deduplicated by Marketing Cloud. Some records may have been suppressed by Marketing Cloud's own suppression lists (global unsubscribes, bounces). The activation may have activated on a different DMO than the one used for segmentation."
                        ),
                        StudyTopic(
                            id: "topic-2.4-q6",
                            number: 6,
                            question: "A related attribute in an activation returns null values. Which mapping relationship should be validated first?",
                            answer: "Validate the DMO relationship between the primary segmentation DMO (e.g., Unified Individual) and the DMO containing the related attribute. Specifically, check that the relationship is Active, and that the foreign key field in the related DMO correctly references the primary DMO's primary key."
                        ),
                        StudyTopic(
                            id: "topic-2.4-q7",
                            number: 7,
                            question: "A consultant configures a related attribute in an activation but the field appears empty for most records. Most likely root causes?",
                            answer: "The foreign key relationship between the DMOs is not correctly mapped or is inactive. The related DMO has low population relative to the primary DMO (many Unified Individuals have no matching record in the related DMO). The related attribute is sourced from a DLO that has not been refreshed recently. The cardinality of the relationship is N:1 and there are multiple matching records, causing the system to return null instead of selecting one."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.5",
                    title: "Use Data Actions and Identify Their Requirements and Intended Use Cases",
                    topics: [
                        StudyTopic(
                            id: "topic-2.5-q1",
                            number: 1,
                            question: "What is a Data Action and how does it differ from a segment activation?",
                            answer: "A Data Action is a near-real-time trigger that fires when a specific event or threshold is met in a Streaming Insight or when a record is created, updated, or deleted in a DMO. It is designed for operational, event-driven, individual record-level use cases. A Segment Activation is a scheduled or continuous batch process that publishes a segment audience to an external target. Data Actions are for individual triggers; activations are for bulk audience delivery."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q2",
                            number: 2,
                            question: "What are the trigger conditions for a Data Action?",
                            answer: "A Streaming Insight threshold (e.g., engagement score drops below 30), a DMO record event (record created, updated, or deleted), or a Calculated Insight value change for a specific record."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q3",
                            number: 3,
                            question: "What action targets are available for Data Actions and what are the use cases for each?",
                            answer: "Salesforce Flow (Autolaunched) is used to create Service Cloud cases, update Contact fields, or send internal notifications. Webhook sends an HTTP POST to an external endpoint and is used to trigger push notifications or send data to third-party systems. Marketing Cloud sends an event to a journey entry source and is used to trigger transactional emails or SMS in near real time."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q4",
                            number: 4,
                            question: "What Salesforce Flow type must be used as a Data Action target?",
                            answer: "An Autolaunched Flow. Screen flows and other flow types that require user interaction cannot be used as Data Action targets."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q5",
                            number: 5,
                            question: "What are the requirements for using a Salesforce Flow as a Data Action target?",
                            answer: "The flow must be an Autolaunched Flow. It must have input variables defined that match the fields being passed from the Data Action, configured as Available for Input. The flow must be active (not in draft status). The user running the flow must have appropriate permissions to execute the flow actions."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q6",
                            number: 6,
                            question: "What input variables must a Flow expose to receive data from a Data Action?",
                            answer: "The flow must expose input variables corresponding to the DMO fields selected in the Data Action configuration. Each field selected in the Data Action maps to a flow input variable by API name. Data types must match between the DMO field and the flow variable."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q7",
                            number: 7,
                            question: "How does a Webhook data action target work and what security considerations apply?",
                            answer: "A Webhook sends an HTTP POST request to a specified external URL whenever the data action fires, with the payload containing the DMO field values selected in the data action. Use HTTPS endpoints only. Configure a secret key or authentication header to verify the request originates from Data Cloud. Ensure the external endpoint can handle the expected request volume. Validate and sanitize the incoming payload on the receiving end."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q8",
                            number: 8,
                            question: "What volume and rate-limit considerations apply to Data Actions?",
                            answer: "Data Actions are designed for event-driven, individual record-level triggers, not high-throughput bulk processing. Salesforce imposes rate limits on the number of data action events processed per unit of time. For high-volume use cases, use Segment Activation instead. Webhook targets must handle the incoming request rate without timing out."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q9",
                            number: 9,
                            question: "A company wants a Data Action to update a custom field on a Contact when a Streaming Insight threshold is crossed. Which target type and Flow configuration achieves this?",
                            answer: "Use a Salesforce Flow (Autolaunched) as the Data Action target. The flow receives the Contact ID and the new field value as input variables from the Data Action. The flow uses a Record Update element to update the custom field on the Contact record. Ensure the flow is optimized to avoid hitting governor limits (e.g., DML statements per transaction) if many records trigger simultaneously."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q10",
                            number: 10,
                            question: "A company wants to open a Service Cloud case when a customer's NPS drops below 6 based on ingested survey data. Which feature combination enables this?",
                            answer: "1. Ingest survey data via Ingestion API (streaming). 2. Create a Streaming Insight with a window function detecting when an individual's NPS drops below 6. 3. Configure a Data Action triggered by the Streaming Insight threshold. 4. Set the Data Action target to a Salesforce Flow (Autolaunched). 5. The flow creates a Service Cloud Case record linked to the customer's Contact record."
                        ),
                        StudyTopic(
                            id: "topic-2.5-q11",
                            number: 11,
                            question: "A company wants a real-time push notification via an external mobile platform when a customer qualifies for a flash sale. Which capability should be used?",
                            answer: "Use a Data Action with a Webhook target. Create a Streaming Insight or DMO record event that fires when a customer qualifies for the flash sale criteria. Configure a Data Action triggered by the insight or event. Set the target to a Webhook pointing to the external mobile platform's push notification API endpoint. Include the customer's mobile device token and notification payload in the data action field selection. Secure the webhook with an authentication header or secret key."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.6",
                    title: "Transformation Capabilities in Data Cloud",
                    topics: [
                        StudyTopic(
                            id: "topic-2.6-q1",
                            number: 1,
                            question: "What transformation capabilities does Data Cloud provide natively?",
                            answer: "Formula fields are applied during data stream configuration to transform individual field values before they are stored in the DLO. Streaming Data Transforms are SQL-based transformations that run continuously on a source DLO and write transformed records to a target DLO. Batch Data Transforms are SQL-based transformations that run on a schedule against one or more DLOs for more complex, multi-source transformations."
                        ),
                        StudyTopic(
                            id: "topic-2.6-q2",
                            number: 2,
                            question: "What is a formula field in Data Cloud and what expression types are supported?",
                            answer: "A formula field is a calculated field added to a DLO during data stream configuration. Supported expressions include string functions (CONCAT, UPPER, LOWER, TRIM, SUBSTRING), conditional logic (IF(), AND(), OR(), NOT()), arithmetic operators (+, -, *, /), type conversion, and bucket values using IF() to categorize numeric ranges into labels like Platinum, Gold, and Silver."
                        ),
                        StudyTopic(
                            id: "topic-2.6-q3",
                            number: 3,
                            question: "What is a Data Transform in Data Cloud?",
                            answer: "A SQL-based transformation process that reads data from one or more source DLOs, applies transformation logic, and writes the results to a target DLO. Streaming Data Transforms run continuously for near-real-time processing. Batch Data Transforms run on a schedule for periodic processing."
                        ),
                        StudyTopic(
                            id: "topic-2.6-q4",
                            number: 4,
                            question: "How does a Data Transform differ from standard field mapping?",
                            answer: "Field mapping (harmonization) maps existing DLO fields to DMO fields without changing the data. A Data Transform actually changes the data by applying SQL logic to create new fields, filter records, join multiple DLOs, or restructure data before it reaches the DMO. Data Transforms are used when the source data requires cleaning or normalization that cannot be achieved through field mapping alone."
                        ),
                        StudyTopic(
                            id: "topic-2.6-q5",
                            number: 5,
                            question: "When should a consultant use a Data Transform versus a formula field?",
                            answer: "Use a formula field for simple, single-field transformations expressible in a formula (e.g., concatenating first and last name, bucketing a numeric value, converting a date format). Use a Streaming Data Transform when you need to split one DLO record into multiple target records, filter records based on complex conditions, join data from multiple DLOs, handle denormalized data that needs normalization, or apply SQL functions not available in formula fields."
                        ),
                        StudyTopic(
                            id: "topic-2.6-q6",
                            number: 6,
                            question: "A company wants to create a full name field in a DMO by concatenating first and last name from a DLO. Which feature should be used?",
                            answer: "Use a formula field during data stream configuration. The formula would be CONCAT(sourceField['FirstName'], ' ', sourceField['LastName']). This creates a new field in the DLO that combines the two source fields, which can then be mapped to the appropriate DMO field."
                        ),
                        StudyTopic(
                            id: "topic-2.6-q7",
                            number: 7,
                            question: "A company receives date fields as Unix epoch timestamps but the DMO requires ISO 8601 format. Which transformation approach should be used?",
                            answer: "Use a Streaming Data Transform with SQL date conversion functions. The transform reads the epoch timestamp from the source DLO, converts it to a datetime value using SQL functions (e.g., FROM_UNIXTIME() or equivalent Trino/Spark SQL function), and writes the converted value to the target DLO. The target DLO is then mapped to the DMO with the correctly formatted date field."
                        ),
                        StudyTopic(
                            id: "topic-2.6-q8",
                            number: 8,
                            question: "What are the limitations of Data Transforms in Data Cloud?",
                            answer: "Streaming Data Transforms can only read from a single source DLO (no multi-source joins in streaming mode). Batch Data Transforms support multi-source joins but have scheduling constraints and are not real-time. Data Transforms cannot write directly to a DMO; they write to a target DLO, which must then be mapped to a DMO. The total number of streaming data transforms is 25 per org. Certain SQL functions available in standard databases may not be supported in Data Cloud's Trino/Spark SQL environment."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.7",
                    title: "Describe Processes and Considerations for Data Ingestion from Different Sources",
                    topics: [
                        StudyTopic(
                            id: "topic-2.7-q1",
                            number: 1,
                            question: "What is the role of the Data Stream primary key?",
                            answer: "The primary key uniquely identifies each record in the DLO. It is used during Upsert operations to determine whether an incoming record should be inserted (new) or updated (existing). A missing or incorrect primary key causes duplicate records in the DLO and breaks downstream identity resolution."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q2",
                            number: 2,
                            question: "What are the differences between Ingestion API (streaming) and Cloud Storage connector (batch)?",
                            answer: "The Ingestion API provides near-real-time data freshness (seconds to minutes), is designed for high-throughput event streams like clickstream and IoT data, and requires higher setup complexity including schema definition and API calls. Cloud Storage is batch-only with low to medium data freshness (hourly or daily), is designed for large file-based loads like nightly exports, and has lower setup complexity (file drop and schedule configuration)."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q3",
                            number: 3,
                            question: "What are the Ingestion API endpoint types available in Data Cloud?",
                            answer: "The Streaming endpoint accepts individual or small batches of records in near real time and is designed for continuous event streams from web and mobile applications. The Bulk endpoint accepts large batches of records in a single API call and is designed for loading large volumes of historical data or periodic bulk updates."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q4",
                            number: 4,
                            question: "What configuration is required before data can be sent via the Ingestion API?",
                            answer: "Create a connected app in Salesforce for OAuth authentication. In Data Cloud, create a new Ingestion API data stream and define the schema (field names, data types, primary key). The schema definition creates the corresponding DLO. Obtain the API endpoint URL and OAuth token for the connected app. Send data payloads that conform to the defined schema (JSON format for streaming, CSV or JSON for bulk)."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q5",
                            number: 5,
                            question: "A company wants to stream clickstream events from its website into Data Cloud in near real time. Which ingestion method and what are the payload requirements?",
                            answer: "Use the Ingestion API (Streaming endpoint) or the Salesforce Web and Mobile SDK. Payloads must be JSON format, conforming to the schema defined in the Ingestion API data stream. Each record must include the primary key field and the event datetime field (for Engagement category data). The payload is sent via HTTP POST with an OAuth bearer token in the Authorization header."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q6",
                            number: 6,
                            question: "What are the key considerations when ingesting data from cloud storage (S3/GCS/Azure Blob)?",
                            answer: "File format must be CSV or Parquet, with GZ and ZIP compression supported for CSV. Configure the polling frequency (e.g., hourly, daily) based on how often new files are delivered. Choose Full Refresh, Upsert, or Delta based on whether the file contains a full snapshot or incremental changes. The Data Cloud connector must have read access to the storage bucket or container."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q7",
                            number: 7,
                            question: "What file format constraints apply to Cloud Storage data streams?",
                            answer: "Supported formats are CSV and Parquet. Compression options for CSV are GZ and ZIP. Compression options for Parquet are GZ, ZIP, SNAPPY, ZSTD, and NONE. Always refer to the latest Salesforce documentation for current limits as they can change with releases."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q8",
                            number: 8,
                            question: "A company has a legacy system that can only export CSV files once per day. What is the recommended ingestion approach?",
                            answer: "Use a Cloud Storage connector (Amazon S3, GCS, or Azure Blob Storage). Use Full Refresh if the file contains the complete current dataset, or Upsert if the file contains only new or changed records. The legacy system exports the CSV to the cloud storage bucket. Data Cloud polls the bucket on a daily schedule and ingests the new file. Ensure consistent file naming, correct CSV formatting (UTF-8 encoding, proper delimiters), and reliable delivery before the Data Cloud polling window."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q9",
                            number: 9,
                            question: "A company needs to ingest Salesforce Service Cloud Case records into Data Cloud. Which connector and what steps are required?",
                            answer: "Use the Salesforce CRM Connector. Configure the connector in Data Cloud Setup with the source org credentials. Assign the Data Cloud Salesforce Connector permission set to the integration user in the source org with Read and View All on the Case object. Create a new Data Stream using the CRM Connector, selecting the Case object and required fields. Set the primary key (Case ID), data category, refresh mode, and schedule. Deploy the data stream and map the resulting DLO to the appropriate DMO."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q10",
                            number: 10,
                            question: "A company uses MuleSoft to integrate with Data Cloud. Which connector or API is leveraged and what are the key setup steps?",
                            answer: "Use the MuleSoft Anypoint Connector for Data Cloud. Install the connector in MuleSoft Anypoint Studio. Configure it with Data Cloud OAuth credentials (connected app). In Data Cloud, create an Ingestion API data stream to define the schema for the data being sent from MuleSoft. In MuleSoft, configure the flow to transform source data and send it to the Data Cloud Ingestion API endpoint. Test the integration and monitor the Data Stream job status in Data Cloud."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q11",
                            number: 11,
                            question: "What happens to existing records in a DLO when a data stream is re-run in Full Refresh versus Upsert mode?",
                            answer: "Full Refresh replaces all existing records in the DLO with records from the new run. Records that existed previously but are not in the new file are deleted from the DLO. Upsert updates existing records if their primary key matches a record in the new file and inserts new records. Records that existed previously but are not in the new file are retained (not deleted)."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q12",
                            number: 12,
                            question: "How does a missing or incorrect primary key affect DLO population and downstream identity resolution?",
                            answer: "A missing primary key means records without a primary key value are excluded from the DLO, resulting in data loss. An incorrect primary key that is not truly unique causes duplicate records in the DLO. During Upsert, the system cannot correctly identify which record to update. Downstream, duplicate or missing records in the DLO lead to incorrect or incomplete data in the Individual DMO, causing over-merging (false positives) or under-merging (false negatives) in the Unified Individual."
                        ),
                        StudyTopic(
                            id: "topic-2.7-q13",
                            number: 13,
                            question: "How are hard-deleted CRM records handled in Data Cloud?",
                            answer: "When a record is hard-deleted in Salesforce CRM, the CRM Connector does not automatically remove it from the Data Cloud DLO. To handle deletions, use Full Refresh mode if the dataset is under 50 million records (which replaces the DLO with only current records), use the Data Cloud Delete API to programmatically delete specific records from a DLO, or implement a soft-delete pattern in the source (e.g., an IsDeleted flag) and use a streaming data transform to filter out deleted records."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.8",
                    title: "Define, Map, and Model Data Using Best Practices for Identity Resolution",
                    topics: [
                        StudyTopic(
                            id: "topic-2.8-q1",
                            number: 1,
                            question: "What is the Data Cloud canonical data model?",
                            answer: "A standardized, pre-built data model designed to be the standard data model across Salesforce systems, platforms, and applications. It includes common definitions for data types, data structures, relationships, and rules. Using it standardizes data from disparate sources and unlocks Salesforce functionality like Einstein AI, segmentation, and activation."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q2",
                            number: 2,
                            question: "Which standard DMO categories exist in Data Cloud?",
                            answer: "Profile is for data about a person or account (e.g., Individual, Account, Lead). Only Profile category DMOs can be segmented upon. Engagement is for behavioral and interaction data with an immutable event datetime field (e.g., email opens, web visits). Other is for miscellaneous data that does not fit Profile or Engagement categories, including engagement data without an immutable event date field."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q3",
                            number: 3,
                            question: "What is the Individual DMO and what role does it play?",
                            answer: "The Individual DMO is the central, required standard DMO in the Party subject area. It represents a person and includes fields such as first name, last name, birth date, and occupation. It is the root entity for identity resolution. All source records representing a person must be mapped to it. The identity resolution process operates on Individual records to create Unified Individual profiles."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q4",
                            number: 4,
                            question: "What is a Contact Point in Data Cloud's data model?",
                            answer: "A Contact Point is a field or set of fields representing a way to contact or engage with an individual, such as an email address or phone number. Contact points are stored in dedicated Contact Point DMOs, linked to the Individual DMO, used in identity resolution matching, and included when creating segment activations."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q5",
                            number: 5,
                            question: "What DMOs fall under the Contact Point category?",
                            answer: "ContactPointEmail stores email addresses linked to an Individual. ContactPointPhone stores phone numbers. ContactPointAddress stores postal addresses. ContactPointApp stores mobile app identifiers such as push notification tokens."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q6",
                            number: 6,
                            question: "What is the Engagement DMO category used for?",
                            answer: "Behavioral and interaction data that is time-series oriented. Data mapped to Engagement DMOs must include an immutable event datetime field (a date that cannot change after the record is created). Examples include email open and click events, web page visit events, case creation events (using the case created date), purchase transaction events, and mobile app session events."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q7",
                            number: 7,
                            question: "What is the difference between a primary key and a foreign key in the Data Cloud data model?",
                            answer: "A primary key uniquely identifies a record in a DMO or DLO and cannot be null (e.g., Salesforce Contact ID in the Individual DMO). A foreign key is a field in one DMO that references the primary key of another DMO, establishing a relationship between the two objects (e.g., the Individual ID field in the ContactPointEmail DMO references the primary key of the Individual DMO)."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q8",
                            number: 8,
                            question: "How are relationships (lookups) between DMOs defined in Data Cloud?",
                            answer: "Relationships are defined in the Data Model tab using the Relationships section of a DMO. You specify the source DLO field (the foreign key field), the cardinality (e.g., many-to-one, one-to-one), and the related DMO and related field (the primary key of the related DMO). Relationships must be activated to be used in segmentation, activation, or identity resolution."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q9",
                            number: 9,
                            question: "What is the difference between mapping to a standard DMO versus a custom DMO?",
                            answer: "Standard DMOs are pre-built by Salesforce as part of the canonical data model. Use them whenever possible because they enable Salesforce functionality like Einstein AI, segmentation, and activation out of the box. Standard DMOs can be extended with custom fields. Custom DMOs are created by the user to accommodate data that does not fit any standard DMO. Use them only when no standard DMO exists. Custom DMOs require manual relationship definitions and may not support all Salesforce features automatically."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q10",
                            number: 10,
                            question: "What best practices should be followed when creating a custom DMO?",
                            answer: "Always check if a standard DMO exists before creating a custom one. Use clear, descriptive names following Salesforce naming conventions. Choose a primary key that is truly unique and immutable. Define relationships to other DMOs (especially the Individual DMO) to enable segmentation and activation. Assign the correct data category (Profile, Engagement, Other). Avoid creating separate DMOs per data source; combine similar data from multiple sources into a single DMO using field mapping."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q11",
                            number: 11,
                            question: "Why are identity-resolution-eligible fields critical when mapping DLOs?",
                            answer: "These are the fields used by matching rules to determine whether two records represent the same person. If they are not correctly mapped in the DLO-to-DMO mapping, the identity resolution process cannot use them for matching, resulting in under-merging (separate Unified Individuals for the same person). Critical fields include email address, phone number, name, and party identification numbers."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q12",
                            number: 12,
                            question: "What fields must be mapped in a DLO for records to be eligible for identity resolution?",
                            answer: "The Individual DMO must be mapped with at least the primary key field. Either a Contact Point DMO (ContactPointEmail, ContactPointPhone, etc.) or the Party Identification DMO must also be mapped. The Party field (foreign key linking the Contact Point or Party Identification back to the Individual) must be mapped."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q13",
                            number: 13,
                            question: "What is the Party Identification DMO and how does it enable cross-source record linkage?",
                            answer: "The Party Identification DMO stores alternative identifiers for an individual, such as a driver's license number, loyalty card number, external customer ID, or mobile SDK shared identifier. It is used in identity resolution when contact points are not available or reliable for matching. The Identification Number field (the identifier value) and the Party field (foreign key to the Individual DMO) are both required fields."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q14",
                            number: 14,
                            question: "How do DMO relationships enable use of related attributes in segmentation and activation?",
                            answer: "When DMO relationships are defined and active, the Segment Builder can access fields from related DMOs as related attributes in the attribute library. This allows filtering segments based on data from related objects (e.g., Individuals who made a purchase in the last 30 days, where purchase data is in a related Sales Order DMO). Activations can also include related attributes from related DMOs in the activation payload."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q15",
                            number: 15,
                            question: "What is the impact of leaving a required field unmapped versus a non-required field unmapped?",
                            answer: "A required field unmapped means records with a null value for that field are excluded from the DMO. For Profile and Other category DMOs, the primary key is required. For Engagement DMOs, both the primary key and the event datetime field are required. A non-required field unmapped means records are still written to the DMO, but the unmapped field will be null for all records, which may affect downstream processes that rely on that field."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q16",
                            number: 16,
                            question: "What happens when a foreign key reference in a DMO does not match any record in the related DMO?",
                            answer: "The relationship lookup returns null for that record. The record is still stored in the DMO but will not be joinable to the related DMO. This results in null values for related attributes in segmentation and activation, and may affect identity resolution if the unmatched foreign key is part of a matching rule."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q17",
                            number: 17,
                            question: "A company has three data sources with customer email addresses stored in differently named fields. How should field-level mapping be configured?",
                            answer: "Create three separate data streams (one per source). For each data stream, map the source email field to the EmailAddress field in the ContactPointEmail DMO, regardless of the source field name. Also map the Party field (foreign key to the Individual DMO) and the primary key for each ContactPointEmail record. All three data streams will contribute records to the same ContactPointEmail DMO, and identity resolution will use email addresses from all three sources for matching."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q18",
                            number: 18,
                            question: "A company is ingesting loyalty program data with email and phone but no CRM account ID. Which DMO and field mappings ensure these records participate in identity resolution?",
                            answer: "Map the loyalty program's customer identifier to the Individual DMO as the primary key. Map the email address to the ContactPointEmail DMO with the Party field linking back to the Individual. Map the phone number to the ContactPointPhone DMO with the Party field linking back to the Individual. Optionally, map the loyalty card number to the Party Identification DMO (Identification Number field, with the Party field linking back to the Individual). Configure identity resolution matching rules to use email (exact) and/or phone (normalized) for matching."
                        ),
                        StudyTopic(
                            id: "topic-2.8-q19",
                            number: 19,
                            question: "A company is building a B2B data model. What standard DMOs should be used and how does this differ from B2C?",
                            answer: "For B2B, use the Account DMO as the root entity and the Account Contact Relationship DMO to link Contacts to Accounts. Identity resolution is based on the Account DMO, and the Unified Account is the output. For B2C, use the Individual DMO as the root entity with Contact Points linked directly to the Individual, and the Unified Individual is the output. The key difference is that B2B requires account-level matching in addition to contact-level matching, and the segmentation target is the Unified Account rather than the Unified Individual."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-2.9",
                    title: "Use Available Tools to Inspect and Validate Ingested and Modeled Data",
                    topics: [
                        StudyTopic(
                            id: "topic-2.9-q1",
                            number: 1,
                            question: "What does the Data Stream job status view show and what statuses indicate a problem?",
                            answer: "It shows the last 50 refresh operations for each data stream, including status, start and end time, number of records processed, and error messages for failed runs. Statuses requiring investigation are Failed (the run did not complete successfully) and Partial Success (some records were rejected due to validation errors)."
                        ),
                        StudyTopic(
                            id: "topic-2.9-q2",
                            number: 2,
                            question: "How can a consultant use Data Explorer to verify DLO population?",
                            answer: "In the Data Explorer tab, select the DLO to inspect. You can view the list of ingested records, apply filters to find specific records, check field values to confirm data types and content are correct, compare record counts between the DLO and the source to identify discrepancies, and validate formula field outputs by checking computed values in the DLO."
                        ),
                        StudyTopic(
                            id: "topic-2.9-q3",
                            number: 3,
                            question: "A consultant wants to run an ad-hoc SQL query against a DMO to verify a transformation. Which tool and syntax?",
                            answer: "Use the Query Editor tab in Data Cloud. It supports Trino SQL syntax for querying DLOs and DMOs. Note that Calculated Insights use Spark SQL, which has some syntax differences. The Query Editor allows you to create multiple workspaces and save queries for reuse. You can query DLOs, DMOs, CI objects, and data graphs."
                        ),
                        StudyTopic(
                            id: "topic-2.9-q4",
                            number: 4,
                            question: "How can Ingestion API response payloads be used to validate whether records were accepted or rejected?",
                            answer: "A 202 Accepted response means records were accepted for processing. A 400 Bad Request response means the payload is malformed or does not match the schema. A 401 Unauthorized response means authentication failed. Check the response body for field-level validation errors that indicate which records were rejected and why."
                        ),
                        StudyTopic(
                            id: "topic-2.9-q5",
                            number: 5,
                            question: "After mapping a DLO to a DMO, a consultant observes fewer records in the DMO than in the DLO. Most likely causes?",
                            answer: "Missing required field mappings cause records without that field to be dropped. Data type mismatches cause records with values that cannot be parsed into the target DMO field data type to be dropped. Duplicate primary keys in the DLO result in only one record per key being retained in the DMO. Category mismatch between the DLO and DMO will cause mapping to fail. Null primary keys cause records to be excluded from the DMO."
                        ),
                    ]
                ),
            ]
        ),
        StudySection(
            id: "section-3",
            title: "Identity Resolution",
            color: Color.purple,
            lightColor: Color.purple.opacity(0.12),
            icon: "person.2.fill",
            objectives: [
                StudyObjective(
                    id: "topic-3.1",
                    title: "Describe Matching and How Its Rule Sets Are Applied",
                    topics: [
                        StudyTopic(
                            id: "topic-3.1-q1",
                            number: 1,
                            question: "What is identity resolution in Data Cloud and what is the output?",
                            answer: "Identity resolution matches and reconciles data about individuals from multiple source records into a single Unified Individual profile. The output includes the Unified Individual DMO (the merged profile record), the Unified Link Individual DMO (a bridge object linking each source Individual record to its Unified Individual), Unified Link Contact Point DMOs (unified versions of email, phone, address, and app contact points), and the Unified Link Party Identification DMO."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q2",
                            number: 2,
                            question: "What is the role of the Individual DMO in identity resolution?",
                            answer: "The Individual DMO is the required root entity for identity resolution. All source records representing a person must be mapped to it. The identity resolution process operates on Individual records, using their linked Contact Point and Party Identification records to find matches across data sources. Identity resolution rulesets are created based on either the Individual DMO (B2C) or the Account DMO (B2B)."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q3",
                            number: 3,
                            question: "What is a matching rule in Data Cloud?",
                            answer: "A matching rule defines the criteria used to determine whether two Individual records represent the same person. Each rule specifies the field(s) to compare (e.g., email address, phone number, full name plus zip code), the matching method (exact, fuzzy, normalized), and whether the match is applied at the Contact Point level or the Individual level."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q4",
                            number: 4,
                            question: "What matching methods are available and what are the trade-offs?",
                            answer: "Exact requires records to match character-for-character, providing high precision but lower recall. Fuzzy allows for minor variations like typos and abbreviations, providing lower precision but higher recall. Normalized standardizes values before comparing (e.g., phone number formatting), providing a balanced approach that reduces false negatives from formatting differences."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q5",
                            number: 5,
                            question: "What is normalization in the context of Data Cloud matching?",
                            answer: "Normalization standardizes field values before comparison. For example, phone numbers like (555) 123-4567 and 5551234567 are normalized to the same format before matching. Email addresses like John.Doe@Example.COM are normalized to john.doe@example.com. Names like Bob and Robert may be normalized using a nickname table."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q6",
                            number: 6,
                            question: "Which fields benefit most from normalization before matching?",
                            answer: "Phone numbers (formatting varies widely across systems), email addresses (case sensitivity, dots in Gmail addresses), names (nicknames, prefixes, suffixes), and addresses (abbreviations like St. versus Street, Ave. versus Avenue)."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q7",
                            number: 7,
                            question: "What happens when a new record matches an existing Unified Individual versus when it creates a new one?",
                            answer: "When a match is found, the new Individual record is linked to the existing Unified Individual via the Unified Link Individual DMO, and the Unified Individual's attributes are updated based on reconciliation rules. When no match is found, a new Unified Individual is created and the new Individual record is linked to it as the sole contributing source record."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q8",
                            number: 8,
                            question: "How are multiple matching rules within an identity resolution ruleset evaluated (AND vs. OR logic)?",
                            answer: "Multiple matching rules within a single ruleset are evaluated with OR logic: a record pair is considered a match if it satisfies any one of the matching rules. Adding more rules increases recall (more matches) but may reduce precision (more false positives). To require multiple criteria to be met simultaneously, combine them within a single rule using multiple fields."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q9",
                            number: 9,
                            question: "What is the difference between a single rule with multiple criteria versus multiple independent rules?",
                            answer: "A single rule with multiple criteria uses AND logic within the rule: both criteria must be met for a match, providing higher precision and lower recall (e.g., email AND full name must both match). Multiple independent rules use OR logic between rules: a match on any single rule is sufficient, providing higher recall and lower precision (e.g., Rule 1 is email match; Rule 2 is phone match; matching on either merges the records)."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q10",
                            number: 10,
                            question: "What is the difference between Contact Point level versus Individual level matching?",
                            answer: "Contact Point level matching makes matches based on shared contact points (e.g., two records share the same email address). This is the most common approach for B2C and operates on the ContactPointEmail or ContactPointPhone DMO. Individual level matching makes matches based on attributes on the Individual record itself (e.g., name plus date of birth). It is used when contact points are not reliable or available."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q11",
                            number: 11,
                            question: "How does the order of matching rules within a ruleset affect which records get merged first?",
                            answer: "Rules are evaluated in the order they are listed in the ruleset. Records that match an earlier rule are merged first. Rule ordering can affect performance and edge cases where records could match multiple rules. Best practice is to place the highest-precision rules first."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q12",
                            number: 12,
                            question: "A company wants to match customers using email (exact) and full name plus zip code (fuzzy). How should the ruleset be structured?",
                            answer: "Configure two matching rules. Rule 1 uses email address with Exact match at the Contact Point level. Rule 2 uses full name (fuzzy) AND zip code (exact) at the Individual level. This means a match on either email OR (name plus zip) will merge records. The exact email rule provides high-precision matches, while the fuzzy name plus zip rule catches records where email is missing or different."
                        ),
                        StudyTopic(
                            id: "topic-3.1-q13",
                            number: 13,
                            question: "Two household members sharing the same email are being merged into a single Unified Individual. Which adjustment prevents this?",
                            answer: "Add an additional criterion to the email matching rule, such as requiring first name to also match (exact or fuzzy). Alternatively, remove the email-only matching rule and replace it with a rule that requires email AND name to match. Another option is to use Party Identification matching (e.g., loyalty card number), which is more unique to an individual."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-3.2",
                    title: "Reconcile Data and Describe How Its Rule Sets Are Applied",
                    topics: [
                        StudyTopic(
                            id: "topic-3.2-q1",
                            number: 1,
                            question: "What is reconciliation in Data Cloud identity resolution?",
                            answer: "Reconciliation determines which field value from competing source records is used to populate the Unified Individual profile when multiple source records have different values for the same field. Reconciliation rules are applied after matching to resolve conflicts."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q2",
                            number: 2,
                            question: "What reconciliation strategies are available in Data Cloud?",
                            answer: "Last Updated (Most Recent) uses the value from the record with the most recent update timestamp and is best when the latest data is most accurate (e.g., current address). Most Frequent uses the value that appears most often across contributing records and is best when the most common value is most reliable (e.g., preferred name). Source Priority uses the value from the highest-priority source system and is best when one system is the authoritative source of record."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q3",
                            number: 3,
                            question: "What does \"Last Updated Wins\" reconciliation require?",
                            answer: "It is equivalent to the Most Recent strategy. It requires that the Last Modified Date field is mapped from the data stream for each contributing DLO. Without this field mapped, the system cannot determine which record was most recently updated and will fall back to another strategy."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q4",
                            number: 4,
                            question: "How does Source Priority reconciliation work and when is it recommended?",
                            answer: "Source Priority sorts DLOs in order of most to least preferred. The value from the highest-priority source is used for the Unified Individual field. If Ignore Empty Values is selected, the process selects the highest-priority non-null value. If multiple values are in the same source, the process uses the last updated date. Source Priority is the recommended solution for ID fields to help stabilize values across identity resolution runs."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q5",
                            number: 5,
                            question: "Do reconciliation rules apply to Contact Point DMOs?",
                            answer: "No. Reconciliation rules do not apply to Contact Point DMOs (email, phone, address, app). All contact points from all contributing source records remain as part of the Unified Individual profile. All contact points are available when creating segment activations. Use the source priority order in activations to deliver a contact point from the desired source to your activation target."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q6",
                            number: 6,
                            question: "What is the Ignore Empty Values option in reconciliation rules?",
                            answer: "When Ignore Empty Values is selected, the system will not select a null value even if null is the most frequently occurring value (for Most Frequent) or the highest-priority value (for Source Priority). This prevents null values from overwriting valid data in the Unified Individual profile."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q7",
                            number: 7,
                            question: "A company has three data sources for customer first name: CRM (most authoritative), loyalty system, and e-commerce. Which reconciliation strategy should be used?",
                            answer: "Use Source Priority reconciliation. Configure the DLO priority order as CRM (highest priority), loyalty system, then e-commerce platform (lowest priority). Enable Ignore Empty Values so that if the CRM has a null first name, the system falls back to the loyalty system value rather than writing null to the Unified Individual."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q8",
                            number: 8,
                            question: "What happens to the Unified Individual when a contributing source record is updated after identity resolution has already run?",
                            answer: "When a contributing source record is updated, the data stream re-runs and updates the DLO. The next identity resolution run re-evaluates the matching and reconciliation rules for the affected records. The Unified Individual is updated with the new reconciled values. If the update changes the matching outcome (e.g., a new email now matches a different Unified Individual), the record linkages are updated accordingly."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q9",
                            number: 9,
                            question: "What is the difference between a golden record (MDM) and a Unified Individual (Data Cloud)?",
                            answer: "A golden record is a single, authoritative, one-dimensional record representing the best known data about a customer, typically static and updated through a governed data stewardship process. A Unified Individual is a comprehensive, multi-dimensional profile that includes the best known attribute values from reconciliation plus all linked contact points, behavioral data, engagement history, and calculated insights. It is continuously updated as new data is ingested and identity resolution re-runs."
                        ),
                        StudyTopic(
                            id: "topic-3.2-q10",
                            number: 10,
                            question: "What happens when an identity resolution ruleset is deleted?",
                            answer: "Deleting a ruleset permanently removes all unified customer data (Unified Individual records and all link objects), eliminates dependencies on data model objects, stops all processing of the ruleset, and deletes the history of previous runs. It is often better to update the match or reconciliation rules instead of deleting the ruleset to avoid losing all unified profile data."
                        ),
                    ]
                ),
            ]
        ),
        StudySection(
            id: "section-4",
            title: "Segmentation and Insights",
            color: Color.orange,
            lightColor: Color.orange.opacity(0.12),
            icon: "chart.pie.fill",
            objectives: [
                StudyObjective(
                    id: "topic-4.1",
                    title: "Build and Publish Segments",
                    topics: [
                        StudyTopic(
                            id: "topic-4.1-q1",
                            number: 1,
                            question: "What is a segment in Data Cloud and what is the Segment On object?",
                            answer: "A segment is a grouping of customers (individuals or accounts) that share a set of characteristics defined by filter criteria. The Segment On object defines the target object used to build the segment and determines which attributes are available in the attribute library. Common Segment On objects include Unified Individual and Unified Account. Only Profile category DMOs can be used as the Segment On object."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q2",
                            number: 2,
                            question: "What are the prerequisites for creating a segment in Data Cloud?",
                            answer: "Identity resolution must have been run to create Unified Individual or Unified Account profiles. The DMO used as the Segment On object must be of the Profile category. DMO relationships must be defined and active for related attributes to be available. The user must have the Data Cloud Marketing Manager or Data Cloud Marketing Specialist permission set."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q3",
                            number: 3,
                            question: "What types of segments can be created in Data Cloud?",
                            answer: "Standard segments are built using the Segment Builder UI with filter criteria on direct and related attributes. Filtered segments are a subset of another segment with additional filter criteria applied. Nested segments include or exclude members of other segments. Waterfall segments are a series of segments where each subsequent segment excludes members of the previous ones, ensuring each customer appears in only one segment. Lookalike segments are generated by Einstein AI based on the characteristics of an existing seed segment."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q4",
                            number: 4,
                            question: "What is the difference between a direct attribute and a related attribute in the Segment Builder?",
                            answer: "A direct attribute is a field that belongs directly to the Segment On DMO (e.g., a field on the Unified Individual DMO itself). A related attribute is a field from a DMO related to the Segment On DMO via a defined DMO relationship (e.g., a purchase amount field from a Sales Order DMO related to the Unified Individual DMO). Related attributes require an active DMO relationship to be available in the attribute library."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q5",
                            number: 5,
                            question: "What are the container types available in the Segment Builder canvas?",
                            answer: "Aggregator groups multiple filter conditions with AND or OR logic. Filtered attribute is a single filter condition on a specific attribute. Path is a sequence of conditions that must be met in a specific order (e.g., a customer who viewed a product page and then added it to cart within 7 days)."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q6",
                            number: 6,
                            question: "What is the role of Calculated Insights in segmentation?",
                            answer: "Calculated Insights create multidimensional metrics (e.g., RFM scores, lifetime value, engagement scores) that can be used as filter criteria in the Segment Builder. CIs enable segmentation based on computed metrics not directly available as raw fields in the DMO. For example, you can segment customers with a lifetime value CI greater than $1,000."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q7",
                            number: 7,
                            question: "How does publishing a segment work and what DMOs are created as a result?",
                            answer: "When a segment is published, Data Cloud evaluates the segment criteria against all Unified Individual (or Unified Account) records and creates a Segment Membership DLO and a Segment Membership DMO to store the list of qualifying profile IDs. Two types of Segment Membership DMOs are created: the Latest Segment Membership DMO (containing profile IDs from the most recent publication) and the Historical Segment Membership DMO (containing profile IDs from the previous publication)."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q8",
                            number: 8,
                            question: "What are the segment publish schedule options in Data Cloud?",
                            answer: "A 12-hour schedule recalculates segment membership every 12 hours. A 24-hour schedule recalculates every 24 hours. Continuous (near real-time) updates segment membership continuously as new data is ingested and processed. Continuous requires additional licensing and is not available for all segment types."
                        ),
                        StudyTopic(
                            id: "topic-4.1-q9",
                            number: 9,
                            question: "What are Fully Qualified Keys (FQKs) and why are they important in segmentation?",
                            answer: "An FQK is the combination of a source key (an identifier field like Contact ID) and a key qualifier (a system-generated value identifying the data source). FQKs prevent conflicts when data from different sources is combined in a DMO field from different DLOs. In segmentation, FQKs ensure that records from different sources are correctly differentiated, especially when the same ID value could exist in multiple source systems."
                        ),
                    ]
                ),
                StudyObjective(
                    id: "topic-4.2",
                    title: "Build and Use Calculated Insights",
                    topics: [
                        StudyTopic(
                            id: "topic-4.2-q1",
                            number: 1,
                            question: "What is a Calculated Insight (CI) in Data Cloud?",
                            answer: "A multidimensional metric computed from data stored in Data Cloud. CIs can calculate metrics at different levels of granularity: individual profile level, segment group level, and complete population level. Examples include RFM scores, engagement scores, churn rates, lifetime value, product affinity scores, and CSAT scores."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q2",
                            number: 2,
                            question: "What SQL dialect is used for Calculated Insights?",
                            answer: "Calculated Insights use Spark SQL syntax. This is different from the Trino SQL used in the Query Editor for ad-hoc queries. Consultants must be aware of the syntax differences between Spark SQL and Trino SQL when writing CI queries."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q3",
                            number: 3,
                            question: "What is the Insight Builder and how does it simplify CI creation?",
                            answer: "The Insight Builder is a no-code/low-code drag-and-drop tool for creating Calculated Insights without writing SQL. It allows users with limited SQL knowledge to build CIs by selecting DMOs, choosing aggregation functions, and defining dimensions and filters. For more complex CIs, the SQL editor can be used directly."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q4",
                            number: 4,
                            question: "What are the key components of a Calculated Insight?",
                            answer: "Dimensions are the grouping fields that define the level of granularity for the metric (e.g., Individual ID, product category, time period). Measures are the aggregated values being calculated (e.g., SUM of purchase amount, COUNT of email opens, AVG of NPS score). Filters are conditions that restrict which records are included in the CI calculation (e.g., only include purchases from the last 90 days)."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q5",
                            number: 5,
                            question: "What types of metrics can be created with Calculated Insights?",
                            answer: "Aggregate metrics use SUM, COUNT, AVG, MIN, or MAX applied to a measure field (e.g., total spend, number of purchases). Non-aggregate metrics are computed values that do not require aggregation (e.g., customer tier based on spend bucket, customer rank, datetime measures). Metrics on metrics are CIs that reference other CI objects as inputs, enabling layered metric calculations."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q6",
                            number: 6,
                            question: "What are common use cases for Calculated Insights?",
                            answer: "RFM scoring (Recency, Frequency, Monetary value), lifetime value (LTV), engagement score (composite score based on email opens, clicks, and web visits), churn risk score (predictive metric based on behavioral signals), product affinity (preference score for a specific product category), and social channel affinity (score indicating which social channel a customer is most likely to engage with)."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q7",
                            number: 7,
                            question: "What is the difference between Calculated Insights and Streaming Insights?",
                            answer: "Calculated Insights are batch-based with scheduled recalculation, can be used in segmentation and data actions, use Spark SQL, and aggregate across the full dataset. Streaming Insights are near-real-time with 1-minute to 24-hour aggregation windows, cannot be used in segmentation (only in data actions), also use Spark SQL (with limited functions), and aggregate using time-based window functions. Streaming Insights are the primary use case for triggering Data Actions."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q8",
                            number: 8,
                            question: "What is a Streaming Insight and when should it be used?",
                            answer: "A Streaming Insight is a near-real-time variant of a Calculated Insight that processes data from continuous event streams using a window function. The aggregation time window ranges from 1 minute to 24 hours. Use Streaming Insights for near-real-time anomaly detection, triggering Data Actions when a threshold is crossed, process orchestration based on real-time event patterns, and alerting sales or service agents to time-sensitive customer signals. Streaming Insights are not available for use in segmentation and activation."
                        ),
                        StudyTopic(
                            id: "topic-4.2-q9",
                            number: 9,
                            question: "What are Real-Time Insights and how do they differ from Calculated and Streaming Insights?",
                            answer: "Real-Time Insights are built on Data Graphs and provide truly real-time processing. They are used when near-real-time processing of large amounts of data is needed, such as augmenting an LLM prompt with current customer context. Real-Time Insights have the lowest latency of the three insight types but require Data Graphs to be configured first."
                        ),
                    ]
                ),
            ]
        ),
        StudySection(
            id: "section-5",
            title: "Activation",
            color: Color.green,
            lightColor: Color.green.opacity(0.12),
            icon: "bolt.fill",
            objectives: [
                StudyObjective(
                    id: "topic-5.1",
                    title: "Configure and Manage Activations",
                    topics: [
                        StudyTopic(
                            id: "topic-5.1-q1",
                            number: 1,
                            question: "What is an activation in Data Cloud and how does it differ from a segment?",
                            answer: "A segment is a grouping of customer profiles that meet defined criteria and exists within Data Cloud. An activation is the process of publishing a segment's audience to an external target system (e.g., Marketing Cloud, advertising platform, cloud storage). The activation delivers the segment members and their associated attributes to the target for use in campaigns, journeys, or other downstream processes."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q2",
                            number: 2,
                            question: "What activation targets are available in Data Cloud?",
                            answer: "Marketing Cloud Engagement delivers segment members to a Marketing Cloud data extension for use in journeys and campaigns. Marketing Cloud Personalization delivers segment members for real-time personalization. Google Ads delivers hashed contact points to Google Customer Match audiences. Meta Ads (Facebook/Instagram) delivers hashed contact points to Meta Custom Audiences. Amazon Ads delivers hashed contact points to Amazon advertising audiences. Cloud Storage (S3, GCS, Azure) delivers segment members as CSV or Parquet files. The Data Cloud Activation API enables programmatic activation for custom targets."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q3",
                            number: 3,
                            question: "What are the key configuration steps for a Marketing Cloud Engagement activation?",
                            answer: "1. Configure the Marketing Cloud Engagement Connector in Data Cloud Setup. 2. Create an Activation Target for Marketing Cloud Engagement, specifying the connected MC account. 3. Create a new Activation, selecting the segment and the activation target. 4. Map the contact point (e.g., email address) to the Marketing Cloud subscriber key. 5. Select additional attributes to include in the activation payload. 6. Configure the activation schedule (publish frequency). 7. Publish the activation."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q4",
                            number: 4,
                            question: "What is the difference between an activation target and an activation?",
                            answer: "An Activation Target is the configuration of the external system where segment data will be delivered (e.g., a specific Marketing Cloud account, a Google Ads account, an S3 bucket). It is configured once and reused across multiple activations. An Activation is the specific configuration that links a segment to an activation target, defines the contact points and attributes to include, and sets the publish schedule. One segment can be activated to multiple activation targets."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q5",
                            number: 5,
                            question: "What is the role of contact points in activation and how does source priority affect which contact point is delivered?",
                            answer: "Contact points (email, phone, mobile app token) are the identifiers used to deliver the activation to the target system. When a Unified Individual has multiple contact points from different sources (e.g., two email addresses from CRM and Marketing Cloud), the source priority order configured in the activation determines which contact point is delivered to the target. The highest-priority source's contact point is used."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q6",
                            number: 6,
                            question: "What are the Activation Audience DMOs and what information do they contain?",
                            answer: "Activation Audience DMOs are automatically created when an activation is created for the first time for any activation target. Each activation target has its own Activation Audience DMO. The DMO contains a unique ID for each segment and the delta type for each record: Added (A) means the profile was added but was not in the previous activation, Deleted (D) means the profile was dropped but was found in the previous run, Unchanged (U) means the profile was in both the current and previous activation, and Updated (P) means the profile's attribute values changed since the previous activation."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q7",
                            number: 7,
                            question: "Why might the number of activation records differ from the number of segment members?",
                            answer: "Segmentation and activation may be performed on different DMOs, causing count differences. If Individual data comes from more than one data stream with attributes mapped to different fields in the DMO, duplicate records could exist in the segment. Segmentation does a distinct count on Individual IDs, whereas activation only deduplicates if the attribute values of the distinct Individual IDs are the same. An N:1 attribute relationship can also cause duplicate activation records. Contact point suppression for opted-out individuals also reduces the activation count."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q8",
                            number: 8,
                            question: "How does Data Cloud handle PII when activating to advertising platforms like Google Ads or Meta Ads?",
                            answer: "Data Cloud hashes PII (personally identifiable information) before sending it to advertising platforms. Email addresses and phone numbers are hashed using SHA-256 before being transmitted to Google Customer Match or Meta Custom Audiences. This is a form of pseudonymization that protects customer privacy while still enabling audience matching on the advertising platform."
                        ),
                        StudyTopic(
                            id: "topic-5.1-q9",
                            number: 9,
                            question: "What is the recommended approach when an activation to Marketing Cloud shows fewer records than expected?",
                            answer: "Check whether segmentation and activation were performed on the same DMO. Verify that Individual data is not coming from more than one data stream with attributes mapped to different fields. Check whether the activation is configured with the correct contact point type. Review the Activation Audience DMO to see the delta types and identify which records were added, deleted, or unchanged. Check the activation error log in the Data Cloud UI for rejected records and their reasons."
                        ),
                    ]
                ),
            ]
        ),
        StudySection(
            id: "section-6",
            title: "Data Cloud Implementation",
            color: Color.indigo,
            lightColor: Color.indigo.opacity(0.12),
            icon: "hammer.fill",
            objectives: [
                StudyObjective(
                    id: "topic-6.1",
                    title: "Implementation Basics and Project Delivery",
                    topics: [
                        StudyTopic(
                            id: "topic-6.1-q1",
                            number: 1,
                            question: "What are the key steps in a Data Cloud implementation project?",
                            answer: "1. Discovery: identify business use cases, data sources, and stakeholders, and prioritize use cases based on business value and implementation complexity. 2. Architecture design: design the data model, identity resolution strategy, segmentation approach, and activation targets. 3. Data profiling: profile source data to understand field names, data types, data quality, and volume. 4. Setup and configuration: configure connectors, data streams, data transforms, DMO mappings, and identity resolution rulesets. 5. Testing and validation: validate data ingestion, identity resolution results, segment membership, and activation delivery. 6. Go-live and monitoring: deploy to production, monitor data stream job statuses, and optimize identity resolution and segmentation."
                        ),
                        StudyTopic(
                            id: "topic-6.1-q2",
                            number: 2,
                            question: "How should use cases be prioritized for a first-time Data Cloud implementation?",
                            answer: "Choose use cases that are high priority for the business (significant revenue impact or cost savings), achievable quickly with available data sources and Data Cloud capabilities, well-defined with clear segment criteria, activation targets, and success metrics, and supported by existing data that is accessible and of sufficient quality. Avoid starting with use cases that require complex data transformations, many data sources, or custom DMOs, as these increase implementation risk."
                        ),
                        StudyTopic(
                            id: "topic-6.1-q3",
                            number: 3,
                            question: "What is a Data Kit in Data Cloud and how is it used?",
                            answer: "A Data Kit is a portable, customizable bundle of independently packageable metadata in the form of templates. It allows you to streamline the Data Cloud package creation and installation process. Data Cloud objects that can be bundled within a Data Kit include data streams, data models (DMOs and relationships), and calculated insights. Data Kits are used to move Data Cloud configurations between environments (e.g., from sandbox to production). Segments, identity resolution rulesets, and activations cannot be bundled in a Data Kit."
                        ),
                        StudyTopic(
                            id: "topic-6.1-q4",
                            number: 4,
                            question: "What are the key considerations for implementing Data Cloud in a sandbox environment?",
                            answer: "Data Cloud sandboxes are separate instances from production and must be provisioned separately. The Salesforce CRM Connector in a sandbox connects to the sandbox org, not the production org. Data volumes in sandbox are typically smaller than production, which may affect identity resolution results. Always test data stream configurations, identity resolution rulesets, and segment criteria in sandbox before deploying to production."
                        ),
                        StudyTopic(
                            id: "topic-6.1-q5",
                            number: 5,
                            question: "What is the Profile Explorer in Data Cloud and how is it used?",
                            answer: "The Profile Explorer is a Data Cloud menu tab that allows users to access and view individual Unified Individual and Unified Account profiles. Users can search by first name, last name, email address, phone number, or individual ID. It is used to validate identity resolution results by reviewing specific unified profiles, check which source records contributed to a Unified Individual, verify that contact points and attributes are correctly reconciled, and investigate discrepancies in unified profile data."
                        ),
                        StudyTopic(
                            id: "topic-6.1-q6",
                            number: 6,
                            question: "What is the Identity Resolution Tableau Dashboard and how is it used?",
                            answer: "The Identity Resolution Tableau Dashboard provides summary statistics for each identity resolution ruleset, including the consolidation rate (the percentage of source Individual records merged into Unified Individuals, where higher is better), total unified profiles (the number of distinct Unified Individuals created), and total source profiles (the number of source Individual records processed). This dashboard is used to evaluate the effectiveness of the identity resolution configuration and identify opportunities to improve matching rules."
                        ),
                        StudyTopic(
                            id: "topic-6.1-q7",
                            number: 7,
                            question: "What are the recommended resources for preparing for the Salesforce Data Cloud Consultant exam?",
                            answer: "The Get to Know Data Cloud curriculum on Partner Learning Camp (PLC), the Prepare for your Salesforce Data Cloud Consultant Credential Trailmix on Trailhead, the Data Cloud Help Documentation on Salesforce Help, the Salesforce Data Cloud YouTube Playlist, and hands-on practice in a trial or sandbox Data Cloud org. Do not use actual exam questions or dumps as this violates the Salesforce code of conduct. *End of Study Guide — Salesforce Data Cloud 360 Consultant Exam*"
                        ),
                    ]
                ),
            ]
        ),
    ]
}
