# 🚀 Jenkins & AWS S3 CI/CD Pipeline

## 📋 개요
이 프로젝트는 **Jenkins**와 **AWS S3**를 이용하여 CI/CD 파이프라인을 구축하는 방법을 설명합니다. 
전체 파이프라인은 다음과 같은 단계로 이루어집니다:

1. 🔗 **Jenkins와 GitHub 간 웹훅 연결**
2. 🌍 **ngrok으로 로컬 Jenkins를 외부에서 접근 가능하게 설정**
3. ⚙️ **Spring Boot 애플리케이션과 AWS RDS 연동**
4. ☁️ **AWS CLI를 이용한 Jenkins의 S3 연동**
5. 📦 **빌드된 JAR 파일을 S3에 업로드**
6. 📦 **S3에 업로드한 해쉬값을 비교하여 최신 버전 판별 후 실행**

이 파이프라인은 개발자가 소스 코드를 GitHub에 푸시하면, Jenkins가 이를 감지하고 자동으로 애플리케이션을 빌드하여 S3에 업로드하는 작업을 자동화합니다. 이 과정을 통해 개발 주기 동안 일관된 배포가 가능해집니다.

---

## 🗺️ 아키텍처 구조
CI/CD 파이프라인의 아키텍처는 아래와 같습니다:

![image (10)](https://github.com/user-attachments/assets/46cef3ff-e523-4ff8-85cd-c3868559e26c)

---

## 🛠️ Jenkins Docker 설치

### Docker로 Jenkins 설치
다음 명령어를 사용하여 Docker 환경에서 Jenkins를 설치합니다:

![](https://velog.velcdn.com/images/yuwankang/post/c867e5e1-72af-4e66-96e8-1588e5fc7825/image.png)

```bash
docker run --name myjenkins --privileged -p 8080:8080 -v $(pwd)/appjardir:/var/jenkins_home/appjar jenkins/jenkins:lts-jdk17
```

필요한 디렉토리를 마운트하여 애플리케이션 JAR 파일을 저장할 수 있도록 설정합니다.

---

## 🌐 ngrok 연동

ngrok을 사용하여 로컬 Jenkins를 외부에서 접근 가능하게 설정합니다. Jenkins 서버가 로컬에 있을 때 GitHub 웹훅을 사용하기 위해 ngrok이 필요합니다:

![](https://velog.velcdn.com/images/yuwankang/post/0fdf5f64-271a-488e-bcf1-22cbeeb9af0f/image.png)


![](https://velog.velcdn.com/images/yuwankang/post/38483567-dc3f-4f8e-9472-dd255439c60f/image.png)

생성된 URL을 GitHub 웹훅 설정에서 사용합니다. ngrok을 사용하면 Jenkins가 로컬 환경에서 실행되더라도 외부의 GitHub와 통신할 수 있습니다.

---

## ☁️ AWS CLI 설치 및 Jenkins 연동

### AWS CLI 설치
Jenkins에서 AWS S3로 JAR 파일을 업로드하려면 AWS CLI가 필요합니다. AWS CLI는 다음 명령어로 설치할 수 있습니다:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

설치 후, `aws configure` 명령어를 사용하여 AWS 자격증명을 설정해야 합니다.

### AWS S3 버킷 생성 및 연동

![](https://velog.velcdn.com/images/yuwankang/post/184f1f25-edea-43a6-a299-72bbe54da77b/image.png)

```
aws s3 mb s3://<버킷이름> --region ap-northeast-2
```

AWS S3에서 새로운 버킷을 생성해, Jenkins 파이프라인에서 AWS CLI를 사용해 빌드된 JAR 파일을 S3에 업로드합니다.

---

## 🧑‍💻 Jenkins 파이프라인 설정

Jenkins 파이프라인을 설정합니다

```groovy
pipeline {
    agent any

    stages {
        stage('Repo Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/jeonguk0201/AWS_Jenkins.git'
                echo "다운로드 완료"
            }
        }

        stage('Build') {
            steps {
                sh 'chmod +x ./gradlew'  
                sh './gradlew bootJar'
                sh "echo $WORKSPACE"
                sh 'md5sum build/libs/step18_empApp-0.0.1-SNAPSHOT.jar > hash.txt'
            }
        }
        
        stage('Copy jar') { 
            steps {
                sh 'aws s3 cp hash.txt s3://ce27-jenkins --acl public-read'
            }
        }
    }
}
```

### 파이프 라인 구축 완료

![](https://velog.velcdn.com/images/yuwankang/post/b6d645bb-e171-4414-9dec-c3da0a5a8ff8/image.png)

---

## 🌐 Aws cli 연동

### 작업 디렉토리 생성 및 S3 버킷과 동기화

1. 먼저 새로운 작업 디렉토리를 생성합니다:
```bash
mkdir aws_study
cd aws_study
```

2. S3 버킷에서 로컬 디렉토리로 파일을 동기화합니다:

![](https://velog.velcdn.com/images/yuwankang/post/4c32dee4-83f5-4cc1-af70-511d7c9b857d/image.png)

```bash
aws s3 sync s3://<버킷이름> .
```

S3에 있는 모든 파일이 로컬 디렉토리로 다운로드됩니다. 위 예시는 `hash.txt`와 JAR 파일이 다운로드된 모습입니다.

---

## Crontab과 shell 스크립트를 활용한 자동화
```bash
BUCKET_NAME="s3://ce27-jenkins"            # S3 버킷명
LOCAL_DIR="/home/ubuntu/aws_study"          # 로컬 디렉토리 경로
HASH_FILE="${LOCAL_DIR}/hash.txt"           # 동기화한 hash.txt 파일 경로
TEMP_HASH_FILE="${LOCAL_DIR}/temp_hash.txt" # 기존 해시 파일의 임시 위치
JAR_FILE="step18_empApp-0.0.1-SNAPSHOT.jar" # 실행할 JAR 파일명

# 1. AWS S3 버킷과 현재 폴더 동기화
echo "[$(date)] S3 버킷과 로컬 디렉토리 동기화 중..."
aws s3 cp "$BUCKET_NAME/hash.txt" "$LOCAL_DIR"
aws s3 sync "$BUCKET_NAME" "$LOCAL_DIR"

# 2. S3에서 동기화한 hash.txt 파일의 해시값 계산
if [ -f "$HASH_FILE" ]; then
  # S3에서 동기화한 hash.txt 파일의 해시값 계산
  REMOTE_HASH=$(md5sum "$HASH_FILE" | awk '{print $1}')

  # 기존 로컬 hash.txt 파일이 있는지 확인 후 해시값 계산 (없으면 빈 문자열)
  if [ -f "$TEMP_HASH_FILE" ]; then
    LOCAL_HASH=$(md5sum "$TEMP_HASH_FILE" | awk '{print $1}')
  else
    LOCAL_HASH=""
  fi

  # 3. 해시값 비교 및 명령어 수행
  if [ "$REMOTE_HASH" != "$LOCAL_HASH" ]; then
    # 기존 로컬 hash.txt 파일을 새로운 해시값으로 업데이트
    cp "$HASH_FILE" "$TEMP_HASH_FILE"

    # 기존 실행 중인 Java 애플리케이션 프로세스 종료
    echo "[$(date)] 기존 Java 애플리케이션 프로세스 종료 중..."
    pkill -f "$JAR_FILE"

    # Java 애플리케이션 재실행
    echo "[$(date)] 해시값이 일치하지 않음: Java 애플리케이션 재시작 중..."
    nohup java -jar "$LOCAL_DIR/$JAR_FILE" &

    echo "[$(date)] Java 애플리케이션이 재시작되었습니다. S3에서 동기화한 hash.txt의 해시값($REMOTE_HASH)이 기존 해시값($LOCAL_HASH)과 일치하지 않았습니다."
  else
    echo "[$(date)] 해시값이 일치하여 Java 애플리케이션을 재시작하지 않았습니다."
  fi
else
  echo "[$(date)] S3에서 동기화한 hash.txt 파일이 존재하지 않습니다."
fi
```

![image (20)](https://github.com/user-attachments/assets/1b7bf86b-4fac-4186-99ed-46436f7b7420)

![image (19)](https://github.com/user-attachments/assets/dbf57b85-d319-46ef-9318-74baf1bb788d)
```bash
* * * * * /home/ubuntu/aws_study/s3_deploy.sh > /home/ubuntu/aws_study/crontab.log 2>&1
```

## Trouble Shooting
### AWS RDS 사용시 탈취 방지를 위한 수정
![image (21)](https://github.com/user-attachments/assets/9daec7b1-7d6f-44bc-a724-a0b35dada423)
```bash
vi .env
sourve .env
```
![image](https://github.com/user-attachments/assets/2a87ec2a-b0f2-4fdd-b927-64ceba1a86fc)


## ✅ 결론

Jenkins와 AWS S3를 연동하여 CI/CD 파이프라인을 구축하고, Spring Boot 애플리케이션을 자동으로 빌드 및 배포하는 과정을 자동화했습니다.

1. GitHub에서 코드가 푸시되면 Jenkins가 이를 감지하여 자동으로 빌드 프로세스를 시작합니다.
2. **ngrok**을 사용하여 로컬에서 실행 중인 Jenkins가 GitHub 웹훅을 받을 수 있도록 설정되었습니다.
3. Jenkins는 **Spring Boot** 애플리케이션을 빌드하고, 데이터베이스와 연동된 상태에서 JAR 파일을 생성합니다.
4. 생성된 JAR 파일은 **AWS CLI**를 통해 **AWS S3** 버킷에 업로드됩니다.

CI/CD 파이프라인은 개발과 배포 사이의 간격을 줄이고, 자동화를 통해 개발 주기의 효율성을 극대화할 수 있었습니다.
