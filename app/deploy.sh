PROJECT_ID=$(gcloud config get project)

gcloud storage buckets list gs://${PROJECT_ID}_workflow_poc > /dev/null 2>&1

if [ $? -gt 0 ]
then
    
    gcloud storage buckets create gs://${PROJECT_ID}_workflow_poc --location="us-central1"

fi

gcloud builds submit --config cloudbuild.yaml