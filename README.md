# 🚀 Jenkins & AWS S3 CI/CD Pipeline

## 📋 개요
이 프로젝트는 **Jenkins**와 **AWS S3**를 이용하여 CI/CD 파이프라인을 구축하는 방법을 설명합니다. 
전체 파이프라인은 다음과 같은 단계로 이루어집니다:

1. 🔗 **Jenkins와 GitHub 간 웹훅 연결**
2. 🌍 **ngrok으로 로컬 Jenkins를 외부에서 접근 가능하게 설정**
3. ⚙️ **Spring Boot 애플리케이션과 DB 연동**
4. ☁️ **AWS CLI를 이용한 Jenkins의 S3 연동**
5. 📦 **빌드된 JAR 파일을 S3에 업로드**

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

## ✅ 결론
