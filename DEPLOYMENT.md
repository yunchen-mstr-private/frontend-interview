# 🚀 Chat API Docker Deployment Guide

This guide covers deploying the Chat API Docker image in various environments.

## 📋 Prerequisites

- Docker installed and running
- Docker Compose (for multi-container deployments)
- Access to a container registry (for remote deployments)

## 🏠 Local Deployment

### Quick Start
```bash
# Clone the repository
git clone <repository-url>
cd service

# Build and run with docker-compose
./docker-scripts.sh compose

# Or using npm scripts
npm run docker:compose
```

### Development Mode
```bash
# Run with hot reload for development
./docker-scripts.sh dev

# Or using npm scripts
npm run docker:dev
```

### Manual Docker Commands
```bash
# Build the image
docker build -t chat-api:latest .

# Run the container
docker run -d \
  --name chat-api-service \
  -p 3000:3000 \
  -e NODE_ENV=production \
  --restart unless-stopped \
  chat-api:latest
```

## ☁️ Cloud Deployment

### AWS ECS (Elastic Container Service)

#### 1. Build and Push to ECR
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name chat-api --region us-east-1

# Tag and push image
docker tag chat-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/chat-api:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/chat-api:latest
```

#### 2. ECS Task Definition
```json
{
  "family": "chat-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::<account-id>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "chat-api",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/chat-api:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "PORT",
          "value": "3000"
        }
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "node -e \"require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })\""],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/chat-api",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### Google Cloud Run

#### 1. Build and Push to GCR
```bash
# Set project ID
export PROJECT_ID=your-project-id

# Build and tag for GCR
docker build -t gcr.io/$PROJECT_ID/chat-api:latest .

# Push to GCR
docker push gcr.io/$PROJECT_ID/chat-api:latest
```

#### 2. Deploy to Cloud Run
```bash
# Deploy the service
gcloud run deploy chat-api \
  --image gcr.io/$PROJECT_ID/chat-api:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 3000 \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10
```

### Azure Container Instances

#### 1. Build and Push to ACR
```bash
# Login to ACR
az acr login --name <registry-name>

# Build and push
docker build -t <registry-name>.azurecr.io/chat-api:latest .
docker push <registry-name>.azurecr.io/chat-api:latest
```

#### 2. Deploy to Container Instances
```bash
# Deploy the container
az container create \
  --resource-group <resource-group> \
  --name chat-api \
  --image <registry-name>.azurecr.io/chat-api:latest \
  --dns-name-label chat-api \
  --ports 3000 \
  --environment-variables NODE_ENV=production PORT=3000
```

### DigitalOcean App Platform

#### 1. Create app.yaml
```yaml
name: chat-api
services:
- name: chat-api
  source_dir: /
  dockerfile_path: Dockerfile
  http_port: 3000
  instance_count: 1
  instance_size_slug: basic-xxs
  environment_slug: node-js
  envs:
  - key: NODE_ENV
    value: production
  - key: PORT
    value: "3000"
```

#### 2. Deploy
```bash
# Deploy using doctl
doctl apps create --spec app.yaml
```

## 🐳 Kubernetes Deployment

### 1. Create Namespace
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: chat-api
```

### 2. Create Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chat-api
  namespace: chat-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chat-api
  template:
    metadata:
      labels:
        app: chat-api
    spec:
      containers:
      - name: chat-api
        image: chat-api:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "3000"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### 3. Create Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: chat-api-service
  namespace: chat-api
spec:
  selector:
    app: chat-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

### 4. Deploy to Kubernetes
```bash
# Apply the configurations
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check deployment status
kubectl get pods -n chat-api
kubectl get services -n chat-api
```

## 🔧 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `production` | Environment mode |
| `PORT` | `3000` | Server port |

## 📊 Monitoring and Health Checks

### Health Check Endpoint
```bash
# Test health
curl http://your-domain/health

# Expected response
{
  "status": "OK",
  "timestamp": "2025-07-31T18:00:00Z"
}
```

### Docker Health Check
The container includes built-in health checks:
- Checks `/health` endpoint every 30 seconds
- Restarts container if health check fails
- 3 retries before marking as unhealthy

### Logs
```bash
# View container logs
docker logs chat-api-service

# Follow logs
docker logs -f chat-api-service

# Using docker-compose
docker-compose logs -f chat-api
```

## 🔒 Security Considerations

### Production Security
1. **Use non-root user** (already configured in Dockerfile)
2. **Limit container resources** (CPU/memory limits)
3. **Use secrets management** for sensitive data
4. **Enable HTTPS** with reverse proxy
5. **Regular security updates**

### Example with Nginx Reverse Proxy
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 🚀 CI/CD Pipeline Examples

### GitHub Actions
```yaml
name: Deploy Chat API

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Build Docker image
      run: docker build -t chat-api:latest .
    
    - name: Login to ECR
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Push to ECR
      run: |
        docker tag chat-api:latest ${{ steps.login-ecr.outputs.registry }}/chat-api:latest
        docker push ${{ steps.login-ecr.outputs.registry }}/chat-api:latest
    
    - name: Deploy to ECS
      run: |
        aws ecs update-service --cluster my-cluster --service chat-api --force-new-deployment
```

### GitLab CI
```yaml
stages:
  - build
  - deploy

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t chat-api:latest .
    - docker tag chat-api:latest $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest

deploy:
  stage: deploy
  script:
    - kubectl set image deployment/chat-api chat-api=$CI_REGISTRY_IMAGE:latest
```

## 📝 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using port 3000
   lsof -i :3000
   
   # Stop existing container
   ./docker-scripts.sh stop
   ```

2. **Container won't start**
   ```bash
   # Check container logs
   docker logs chat-api-service
   
   # Check container status
   docker ps -a
   ```

3. **Health check failing**
   ```bash
   # Test health endpoint manually
   curl http://localhost:3000/health
   
   # Check container resources
   docker stats chat-api-service
   ```

### Performance Tuning

1. **Increase memory limit**
   ```bash
   docker run -d \
     --name chat-api-service \
     -p 3000:3000 \
     --memory=1g \
     --cpus=1.0 \
     chat-api:latest
   ```

2. **Enable logging rotation**
   ```bash
   docker run -d \
     --name chat-api-service \
     -p 3000:3000 \
     --log-driver json-file \
     --log-opt max-size=10m \
     --log-opt max-file=3 \
     chat-api:latest
   ```

## 📞 Support

For deployment issues:
1. Check container logs
2. Verify environment variables
3. Test health endpoint
4. Review resource limits
5. Check network connectivity

The Chat API is designed to be lightweight and production-ready. Follow these deployment guides for a smooth deployment experience! 