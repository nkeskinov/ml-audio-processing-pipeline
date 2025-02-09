# ML Audio Processing Pipeline

## Prerequisites
1. Authenticate and configure gcloud CLI:

   `gcloud auth login`

   `gcloud config set project <your_project_name>`

2. Enable the following APIs:	*(list is probably not exhaustive)*
   ```
   gcloud services enable eventarc.googleapis.com \
      eventarcpublishing.googleapis.com \
      workflows.googleapis.com \
      workflowexecutions.googleapis.com \
      aiplatform.googleapis.com \
      run.googleapis.com \
      cloudbuild.googleapis.com \
      artifactregistry.googleapis.com \
      bigquery.googleapis.com \
      storage.googleapis.com
   ```
3. Create a workflow-poc service account:
   ```
   gcloud iam service-accounts create workflow-poc \
    --description="Workflow POC Service Account" \
    --display-name="Workflow POC"
   ```
4. Add the follwoing roles to you Workflow POC service account (we're using it for everything, so it's a bunch of roles) (HOWTO: https://cloud.google.com/iam/docs/grant-role-console):
   
   ![image](https://github.com/SaschaHeyer/ml-audio-processing-pipeline/assets/89016113/1db2a344-e708-41f8-a57a-bfde05f7713c)

5. We need to enable some service agents to act as our workflow-poc service account (the PROJECT_NUMBER runs for a while in case of DOIT organisation, as we have a bunch of projects):
   ```
   PROJECT_ID=$(gcloud config get project)
   PROJECT_NUMBER=$(gcloud projects list --filter=$PROJECT_ID --format="value(PROJECT_NUMBER)")

   gcloud iam service-accounts add-iam-policy-binding \
      --role=roles/iam.serviceAccountAdmin \
      --member=serviceAccount:service-$PROJECT_NUMBER@cloud-ml.google.com.iam.gserviceaccount.com \
      workflow-poc@$PROJECT_ID.iam.gserviceaccount.com

   gcloud iam service-accounts add-iam-policy-binding \
      --role=roles/iam.serviceAccountAdmin \
      --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
      workflow-poc@$PROJECT_ID.iam.gserviceaccount.com

   gcloud iam service-accounts add-iam-policy-binding \
      --role=roles/iam.serviceAccountAdmin \
      --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-aiplatform.iam.gserviceaccount.com \
      workflow-poc@$PROJECT_ID.iam.gserviceaccount.com
   ```
6. Make sure the gcr.io repository is in your Artifact Registry:
   ```
   gcloud artifacts repositories create gcr.io \
    --repository-format=docker \
    --location=us
   ```
7. Authenticate Cloud Build with Coud Run (https://cloud.google.com/build/docs/securing-builds/configure-access-for-cloud-build-service-account#service-account-permissions-settings)

## Setup

### Deploy model
The model is a multi step process run in this order `model/build.sh`, `model/upload.sh`, `model/deploy.sh`

### Deploy services
Each service has it's own subfolder containing a `deploy.sh` that runs a Cloud Build step. 

### BigQuery
The pipeline result is stored in BigQuery. 

Create table with schema:

````
bq mk ml_audio_processing_workflow

!bq mk --table \
--description "Table contains the outpt of the ml audio processing workflow" \
--schema "audio_file:STRING,spectogram_image:STRING,prediction:STRING" \
ml_audio_processing_workflow.processed
````

### UI
The demo ui can be deployed with `app/deploy.sh`

### Workflow
Finally, run the `deploy.sh` to deploy the Workflow and Eventarc triggerer
