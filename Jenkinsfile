pipeline { 
    agent any 
 
    stages { 
        stage('Clone Backend') { 
            steps { 
                dir('backend') { 
                    git branch: 'main', url: 'https://github.com/Nabin0819/youtubeclone-backend.git' 
                } 
            } 
        } 
 
        stage('Build & Push Backend Image') { 
            steps { 
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 
'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) { 
                    script { 
                        def backendImage = "${env.DOCKER_HUB_USERNAME}/youtube-backend:v1.1" 
                        sh """ 
                            echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME -
password-stdin 
                            cd backend 
                            docker build -t ${backendImage} . 
                            docker push ${backendImage} 
                        """ 
                    } 
                } 
            } 
        } 
 
        stage('Clone Frontend') { 
            steps { 
                git branch: 'main', url: 'https://github.com/Nabin0819/youtubeclone-frontend.git' 
            } 
        } 
 
        stage('Build & Push Frontend Image') { 
            steps { 
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 
'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) { 
                    script { 
                        def frontendImage = "${env.DOCKER_HUB_USERNAME}/youtube-frontend:v1.1" 
                        sh """ 
                            echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME -
password-stdin 
                            docker build -t ${frontendImage} . 
                            docker push ${frontendImage} 
                        """ 
                    } 
                } 
            } 
        } 
 
        stage('Deploy to EC2') { 
            steps { 
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 
'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) { 
                    sshagent(credentials: ['ec2-ssh-key']) { 
                        sh """ 
                        ssh -o StrictHostKeyChecking=no ubuntu@15.206.216.10 << EOF 
                            DOCKER_HUB_USERNAME=$DOCKER_HUB_USERNAME 
                            DOCKER_HUB_PASSWORD=$DOCKER_HUB_PASSWORD 
 
                            sudo apt update 
                            sudo apt install -y docker.io 
                            sudo systemctl enable docker 
                            sudo systemctl start docker 
 
                            echo $DOCKER_HUB_PASSWORD | sudo docker login -u $DOCKER_HUB_USERNAME --password-stdin 
 
                            sudo docker pull $DOCKER_HUB_USERNAME/youtube-backend:v1.1 
                            sudo docker pull $DOCKER_HUB_USERNAME/youtube-frontend:v1.1 
 
                            sudo docker stop youtube-backend || true 
                            sudo docker rm youtube-backend || true 
                            sudo docker stop youtube-frontend || true 
                            sudo docker rm youtube-frontend || true 
 
                            sudo docker run -d --name youtube-backend -p 5000:5000 
$DOCKER_HUB_USERNAME/youtube-backend:v1.1 
                            sudo docker run -d --name youtube-frontend -p 3000:80 
$DOCKER_HUB_USERNAME/youtube-frontend:v1.1 
EOF 
                        """ 
                    } 
                } 
            } 
        } 
    } 
}
