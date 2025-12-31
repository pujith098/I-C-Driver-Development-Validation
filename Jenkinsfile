pipeline {
    agent {
        label 'raspberrypi'
    }

    options {
        timestamps()
        timeout(time: 90, unit: 'MINUTES')
    }

    environment {
        DRIVER_DIR = 'driver'
        DTS_DIR    = 'dts'
        SCRIPTS    = 'scripts'
        LOG_DIR    = 'logs'
        // Critical for Jenkins non-interactive shell
        PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
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
                    sudo apt-get update
                    sudo apt-get install -y \
                        i2c-tools \
                        build-essential \
                        device-tree-compiler \
                        bc \
                        python3

                    echo "PATH=$PATH"
                    which i2cdetect
                    ls -l /dev/i2c-*
                '''
            }
        }

        stage('Build Driver & DTS') {
            steps {
                sh '''
                    echo "===== BUILD ====="
                    make clean
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
                    sleep 2
                '''
            }
        }

        stage('I2C Sanity Check') {
            steps {
                sh '''
                    echo "===== I2C SANITY ====="

                    echo "--- Loaded modules ---"
                    lsmod | grep i2c_lcd_2004a || exit 1

                    echo "--- I2C Bus Scan ---"
                    i2cdetect -y 1
                '''
            }
        }

        stage('Run Validation Tests') {
            steps {
                sh '''
                    echo "===== VALIDATION TESTS ====="
                    bash scripts/run_tests.sh
                '''
            }
        }
    }

    post {
        always {
            sh '''
                echo "===== COLLECT LOGS ====="
                mkdir -p logs
                bash scripts/collect_logs.sh || true
            '''
            archiveArtifacts artifacts: 'logs/**', fingerprint: true

            sh '''
                echo "===== CLEANUP ====="
                sudo bash scripts/unload_driver.sh || true
            '''
        }

        success {
            echo "✅ I2C LCD VALIDATION PASSED"
        }

        failure {
            echo "❌ I2C LCD VALIDATION FAILED"
        }
    }
}

