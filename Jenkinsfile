//SCRIPTED

//DECLARATIVE
pipeline {
	//agent any
	
	// agent { docker { image 'node:13.8'} }

	 agent {
    docker {
      image 'abhishekf5/maven-abhishek-docker-agent:v1'
	  //image 'maven:3.6.3'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
     }
	 }
	environment {
		dockerHome = tool 'myDocker'
		mavenHome = tool 'myMaven'
		PATH = "$dockerHome/bin:$mavenHome/bin:$PATH"
	}

	stages {
		stage('Checkout') {
			steps {
				echo "PATH - $PATH"
				sh 'mvn --version'
				sh 'docker version'
				echo "Build"
				
				echo "BUILD_NUMBER - $env.BUILD_NUMBER"
				echo "BUILD_ID - $env.BUILD_ID"
				echo "JOB_NAME - $env.JOB_NAME"
				echo "BUILD_TAG - $env.BUILD_TAG"
				echo "BUILD_URL - $env.BUILD_URL"
			}
		}
		stage('Compile') {
			steps {
				sh "mvn clean compile"
			}
		}

		/* stage('Test') {
			steps {
				sh "mvn test"
			}
		}

		stage('Integration Test') {
			steps {
				sh "mvn failsafe:integration-test failsafe:verify"
			}
		} */

		stage('Package') {
			steps {
				sh "mvn package -DskipTests"
			}
		}

		stage('Static Code Analysis') {
      		environment {
        		SONAR_URL = "http://3.99.178.112:9000"
      		}
      		steps {
        		withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_AUTH_TOKEN')]) {
          			sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        			}
      			}
    	}

		 stage('Build Docker Image') {
			steps {
				//"docker build -t in28min/currency-exchange-devops:$env.BUILD_TAG"
				script {
					//dockerImage = docker.build("azax1234/spring-boot-app:0.0.0.${env.BUILD_TAG}")
					dockerImage = docker.build("azax1234/spring-boot-app:0.0.0.${BUILD_NUMBER}")
				}

			}
		}

		stage('Push Docker Image') {
			steps {
				script {
					docker.withRegistry('', 'dockerhub') {
						dockerImage.push();
						dockerImage.push('latest');
					}
				}
			}
		}
	// You can actualy run the image as well. need to have docker installed in the node
	
	 	stage('Run Docker Image') {
			steps {
				sh "docker run -d -p 8075:8075 azax1234/spring-boot-app:0.0.0.${BUILD_NUMBER}"
			}
			}
		
	} 
	 
	post {
		always {
			echo 'Im awesome. I run always'
		}
		success {
			echo 'I run when you are successful'
		}
		failure {
			echo 'I run when you fail'
		}
	}
}
