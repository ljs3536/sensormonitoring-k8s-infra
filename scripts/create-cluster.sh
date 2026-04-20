# 1. 기존 클러스터 미련 없이 삭제
k3d cluster delete sensor-cluster

# 2. 클러스터 재생성 (포트 매핑 완벽 적용!)
k3d cluster create sensor-cluster \
  --servers 1 \
  --agents 4 \
  -p "8080:80@loadbalancer" \
  -p "8001:8001@agent:1" \
  -p "8002:8002@agent:2" \
  -p "8000:8000@agent:3"

# 3. 노드 라벨링 다시 달아주기
kubectl label nodes k3d-sensor-cluster-agent-0 node-role=data
kubectl label nodes k3d-sensor-cluster-agent-1 node-role=app
kubectl label nodes k3d-sensor-cluster-agent-2 node-role=ai
kubectl label nodes k3d-sensor-cluster-agent-3 node-role=edge

# 4. 이미지 한 번에 Import 하기 (띄어쓰기로 구분하면 한방에 됩니다!)
k3d image import sensor-frontend:v1 sensor-backend:v1 sensor-ai:v1 sensor-emulator:v1 sensor-collector:v1 -c sensor-cluster

# 5. 기존에 만들어둔 YAML 파일들 순서대로 싹 다 배포!
kubectl apply -f sensor-secrets.yaml
kubectl apply -f 00-configmap.yaml
kubectl apply -f 01-mosquitto.yaml
kubectl apply -f 02-influxdb.yaml
kubectl apply -f 03-mariadb.yaml
kubectl apply -f 04-backend.yaml
kubectl apply -f 05-frontend.yaml
kubectl apply -f 06-collector.yaml
kubectl apply -f 07-emulator.yaml
kubectl apply -f 08-ai.yaml