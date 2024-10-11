# 🚀 Jenkins & AWS CI/CD Pipeline

## :raising_hand: 팀원

| <img src="https://github.com/yuwankang.png" width="80"> | <img src="https://github.com/recoild.png" width="80"> | <img src="https://github.com/jeonguk0201.png" width="80"> | <img src="https://github.com/cshharry.png" width="80"> |
|:---:|:---:|:---:|:---:|
| [강유완](https://github.com/yuwankang) | [안재형](https://github.com/recoild) | [이정욱](https://github.com/jeonguk0201) | [조성현](https://github.com/cshharry) |

## 📋 개요
**Jenkins**와 **AWS S3**를 이용하여 **CI/CD** 파이프라인을 구축해 개발과 배포 사이의 간격을 줄이고 동화를 통해 개발 주기의 효율성을 극대화하고, **EC2**를 통한 서비스를 구동합니다. 전체 파이프라인은 다음과 같은 단계로 이루어집니다:

1. 🔗 [**Jenkins와 GitHub 간 웹훅 연결**](#jenkins-github-연동)
2. 🌍 [**ngrok으로 로컬 Jenkins를 외부에서 접근 가능하게 설정**](#ngrok-연동)
3. ⚙️ [**Spring Boot 애플리케이션과 AWS RDS 연동**](#aws-cli-설치-및-jenkins-연동)
4. ☁️ [**AWS CLI를 이용한 Jenkins의 S3 연동**](#aws-cli-설치-및-jenkins-연동)
5. 📦 [**빌드된 JAR 파일을 S3에 업로드**](#aws-cli-설치-및-jenkins-연동)
6. 📜 [**S3에 업로드한 해쉬값을 비교하여 최신 버전 판별 후 EC2 실행**](#aws-cli-설치-및-jenkins-연동)
7. 📢 [**Jenkins 슬랙 알림 설정**](#jenkins-파이프라인-slack-알림-설정)

---

## 🛠️ 기술 스택
> 다음과 같은 기술 스택을 사용하여 CI/CD 파이프라인을 구축하고 애플리케이션을 배포하였습니다:

- 1. 🐋 **Docker Jenkins**를 컨테이너화하여 관리 및 실행 환경을 표준화
- 2. 🧩 **Jenkins	CI/CD** 파이프라인을 자동화하고 GitHub와 연동하여 빌드를 관리
- 3. ☁️ **AWS S3**	빌드된 JAR 파일을 저장하고 배포를 위한 버킷으로 사용
- 4. 🐘 **AWS RDS**	MySQL 데이터베이스를 사용하여 Spring Boot 애플리케이션과 연동
- 5. 🧑‍💻 **ngrok**	로컬 Jenkins 서버를 외부에서 접근할 수 있도록 터널링
- 6. 🌱 **Spring Boot**	Java 기반 애플리케이션 프레임워크로, API 및 웹 애플리케이션 구축
- 7. 🐧 **Linux	EC2** 인스턴스에서 애플리케이션을 호스팅하고 관리하기 위한 OS
- 8. 📡 **Slack**	빌드 및 배포 상태를 알리기 위한 알림 시스템으로 사용
- 9. 📜 **GitHub**	소스 코드 버전 관리 및 Jenkins와 연동하여 자동 빌드 트리거
- 10. 💾 **AWS CLI**	Jenkins에서 AWS S3에 파일을 업로드하고 관리하는 도구



> 이 파이프라인은 개발자가 소스 코드를 GitHub에 푸시하면, Jenkins가 이를 감지하고 자동으로 애플리케이션을 빌드하여 S3에 업로드하는 작업을 자동화합니다. 이 과정을 통해 개발 주기 동안 일관된 배포가 가능해집니다.

---

## 🗺️ 아키텍처 구조
CI/CD 파이프라인의 아키텍처는 아래와 같습니다:

![화면 캡처 2024-10-11 160435](https://github.com/user-attachments/assets/676478be-2c90-4cbb-ab58-bdc08a0e8b28)

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
                // dir('01.java/SpringApp') {  
                    sh 'chmod +x ./gradlew'  
                    sh './gradlew bootJar'
                    sh "echo $WORKSPACE"  
                    
                    sh 'md5sum build/libs/step18_empApp-0.0.1-SNAPSHOT.jar > hash.txt'
                // }
            }
        }
        
         stage('Copy jar') { 
            steps {
                // script {
                //     // def jarFile = '01.java/SpringApp/build/libs/step18_empApp-0.0.1-SNAPSHOT.jar'                   
                //     // sh "cp ${jarFile} /var/jenkins_home/appjar/"
                // }
                sh 'aws s3 cp build/libs/step18_empApp-0.0.1-SNAPSHOT.jar s3://ce27-jenkins --acl public-read' 
                
                sh 'aws s3 cp hash.txt s3://ce27-jenkins  --acl public-read' 
            }
        }
    }
    post {
        always {
            slackSend(
                tokenCredentialId: 'token',
                color: '#FFFF00',
                message: "빌드 완료: ${env.JOB_NAME} [${env.BUILD_NUMBER}]"
            )
        }
        success {
            slackSend(
                tokenCredentialId: 'token',
                color: '#00FF00',
                message: "빌드 성공: ${env.JOB_NAME} [${env.BUILD_NUMBER}]"
            )
        }
        failure {
            slackSend(
                tokenCredentialId: 'token',
                color: '#FF0000',
                message: "빌드 실패: ${env.JOB_NAME} [${env.BUILD_NUMBER}]"
            )
        }
    }
}
```

### 파이프 라인 구축 완료

![image](https://github.com/user-attachments/assets/09829d67-b15d-421e-9283-bb43bec6b098)


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

## 🚀 Crontab과 Shell 스크립트를 활용한 자동화
### 📜 스크립트 설명

```bash
#!/bin/bash

# 변수 설정
BUCKET_NAME="s3://ce27-jenkins"            # S3 버킷명
LOCAL_DIR="/home/ubuntu/aws_study"          # 로컬 디렉토리 경로
HASH_FILE="${LOCAL_DIR}/hash.txt"           # 동기화한 hash.txt 파일 경로
TEMP_HASH_FILE="${LOCAL_DIR}/temp_hash.txt" # 기존 해시 파일의 임시 위치
JAR_FILE="step18_empApp-0.0.1-SNAPSHOT.jar" # 실행할 JAR 파일명

# 1. AWS S3 버킷과 현재 폴더 동기화
echo "[$(date)] S3 버킷과 로컬 디렉토리 동기화 중..."
rm -f "$BUCKET_NAME/hash.txt"
aws s3 cp "$BUCKET_NAME/hash.txt" "$LOCAL_DIR/hash.txt"

# 2. S3에서 동기화한 hash.txt 파일의 해시값 계산
if [ -f "$HASH_FILE" ]; then
  # S3에서 동기화한 hash.txt 파일의 해시값 계산
  REMOTE_HASH=$(cat "$HASH_FILE" | awk '{print $1}')

  sleep 1

  # 기존 로컬 hash.txt 파일이 있는지 확인 후 해시값 계산 (없으면 빈 문자열)
  if [ -f "$TEMP_HASH_FILE" ]; then
    LOCAL_HASH=$(cat "$TEMP_HASH_FILE" | awk '{print $1}')
  else
    LOCAL_HASH=""
  fi


  echo "[$(date)] remote: $REMOTE_HASH, local: $LOCAL_HASH..."

  # 3. 해시값 비교 및 명령어 수행
  if [ "$REMOTE_HASH" != "$LOCAL_HASH" ]; then
    # 기존 로컬 hash.txt 파일을 새로운 해시값으로 업데이트
    cp "$HASH_FILE" "$TEMP_HASH_FILE"

    # 기존 실행 중인 Java 애플리케이션 프로세스 종료
    echo "[$(date)] 기존 Java 애플리케이션 프로세스 종료 중..."
    pkill -f "$JAR_FILE"

    echo "[$(date)] Jar 파일 다운로드 중..."
    aws s3 cp "$BUCKET_NAME/$JAR_FILE" "$LOCAL_DIR/$JAR_FILE"

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

### 🕑 Crontab 설정

![image (19)](https://github.com/user-attachments/assets/dbf57b85-d319-46ef-9318-74baf1bb788d)
```bash
* * * * * /home/ubuntu/aws_study/s3_deploy.sh > /home/ubuntu/aws_study/crontab.log 2>&1
```

## 📢 Jenkins 파이프라인 Slack 알림 설정

1. **Slack 토큰 생성 및 앱 추가** 
![image](https://github.com/user-attachments/assets/2b748b35-84c7-4eb4-b6ea-2e18e504060d)

2. **Jenkins 관리 -> System -> Secret text -> 통합 토큰 자격 증명 ID 입력**
![](https://velog.velcdn.com/images/yuwankang/post/7f0d49f9-ee6b-4143-9e1a-2ccc1b5f397b/image.png)

![](https://velog.velcdn.com/images/yuwankang/post/7d920b11-62f9-4eeb-b4e7-159b7b37fb39/image.png)

3. **성공 시 Slack 알림**  
![](https://velog.velcdn.com/images/yuwankang/post/23afc166-06fc-484f-9275-28e4870b7f44/image.png)


## 🛠 Trouble Shooting
### AWS RDS 사용시 보안 수정
![image (21)](https://github.com/user-attachments/assets/9daec7b1-7d6f-44bc-a724-a0b35dada423)
```bash
vi .env
source .env
```
![image](https://github.com/user-attachments/assets/2a87ec2a-b0f2-4fdd-b927-64ceba1a86fc)
### 예전 해쉬값 불러오는 현상

![image](https://github.com/user-attachments/assets/96e34067-568e-4f8b-b19f-fc6f5721b9ee)

**문제 원인**

crontab이 root 계정에서 실행되고, local_hash.txt 파일을 root 권한으로 생성한 후, ubuntu 사용자가 이를 읽거나 수정하려고 하면 권한 문제로 인해 변경 사항이 반영되지 않을 수 있습니다.

root와 ubuntu 계정 간의 권한 충돌로 인해 ubuntu 계정에서 파일을 접근하거나 수정하지 못하는 경우, 해시값 비교에서 항상 일치하지 않는 문제로 보일 수 있습니다.


## ✅ 결론

Jenkins와 AWS S3를 연동하여 CI/CD 파이프라인을 구축하고, Spring Boot 애플리케이션을 자동으로 빌드 및 배포하는 과정을 자동화했습니다.

1. GitHub에서 코드가 푸시되면 Jenkins가 이를 감지하여 자동으로 빌드 프로세스를 시작합니다.
2. **ngrok**을 사용하여 로컬에서 실행 중인 Jenkins가 GitHub 웹훅을 받을 수 있도록 설정되었습니다.
3. Jenkins는 **Spring Boot** 애플리케이션을 빌드하고, 데이터베이스와 연동된 상태에서 JAR 파일을 생성합니다.
4. 생성된 JAR 파일은 **AWS CLI**를 통해 **AWS S3** 버킷에 업로드됩니다.
5. **Slack 알림**을 설정하여 빌드 성공, 실패 시 개발 팀이 즉각적으로 상태를 확인할 수 있습니다. 이를 통해 팀이 신속하게 문제를 대응할 수 있습니다.

CI/CD 파이프라인은 개발과 배포 사이의 간격을 줄이고, 자동화를 통해 개발 주기의 효율성을 극대화했습니다. Slack 알림을 통해 실시간으로 빌드 상태를 확인함으로써 개발 과정에서의 투명성과 반응 속도 또한 향상되었습니다.
