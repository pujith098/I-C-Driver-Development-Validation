pipeline {
    agent {
        label 'raspberrypi'
    }

    options {
        timestamps()
        ansiColor('xterm')
        timeout(time: 90, unit: 'MINUTES')
    }

    environment {
        PROJECT_NAME = "I2C-Driver-Development-Validation"
        LOG_DIR      = "logs"
        TEST_DIR     = "tests"
    }

    stages {

        stage('Checkout') {
            steps {
                cleanWs()
                git branch: 'main',
                    url: 'https://github.com/pujith098/I-C-Driver-Development-Validation.git'
            }
        }

        stage('Setup Environment') {
            steps {
                sh '''
                    echo "===== SETUP ENV ====="
                    bash scripts/setup_env.sh
                '''
            }
        }

        stage('Build Driver & DTS') {
            steps {
                sh '''
                    echo "===== BUILD ====="
                    make clean || true
                    make
                '''
            }
        }

        stage('Load Driver & Overlay') {
            steps {
                sh '''
                    echo "===== LOAD DRIVER ====="
                    sudo bash scripts/unload_driver.sh || true
                    sudo bash scripts/load_driver.sh
                '''
            }
        }

        stage('I2C Sanity Check') {
            steps {
                sh '''
                    echo "===== I2C SANITY ====="
                    lsmod | grep i2c_lcd_2004a
                    i2cdetect -y 1
                    ls /sys/bus/i2c/devices/1-0027 || exit 1
                '''
            }
        }

        stage('Run Validation Tests') {
            steps {
                sh '''
                    echo "===== RUN TESTS ====="
                    cd tests
                    bash framework/test_framework.sh
                '''
            }
        }
    }

    post {

        always {
            sh '''
                echo "===== COLLECT LOGS ====="
                bash scripts/collect_logs.sh
            '''

            archiveArtifacts artifacts: 'logs/**/*', fingerprint: true
            archiveArtifacts artifacts: 'tests/**/tc_*.sh', fingerprint: false
            archiveArtifacts artifacts: 'driver/*.ko', fingerprint: true
        }

        success {
            echo '✅ I2C Validation PASSED'
        }

        failure {
            echo '❌ I2C Validation FAILED'
        }

        cleanup {
            sh '''
                echo "===== CLEANUP ====="
                sudo bash scripts/unload_driver.sh || true
            '''
        }
    }
}

