pipeline {
    agent {
        label 'raspberrypi'
    }

    options {
        timestamps()
    }

    environment {
        DRIVER_DIR = 'driver'
        DTS_DIR    = 'dts'
        LOG_DIR    = 'logs'
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Environment') {
            steps {
                sh '''
                    echo "===== SYSTEM INFO ====="
                    uname -a

                    echo "===== I2C DEVICES ====="
                    ls -l /dev/i2c* || true
                '''
            }
        }

        stage('Build I2C Driver') {
            steps {
                sh '''
                    echo "===== BUILD DRIVER ====="
                    cd ${DRIVER_DIR}
                    make clean || true
                    make
                '''
            }
        }

        stage('Load Driver') {
            steps {
                sh '''
                    echo "===== LOAD DRIVER ====="
                    sudo rmmod i2c_dummy_driver 2>/dev/null || true
                    sudo insmod ${DRIVER_DIR}/i2c_dummy_driver.ko
                    dmesg | tail -20
                '''
            }
        }

        stage('I2C Detect') {
            steps {
                sh '''
                    echo "===== I2C SCAN ====="
                    i2cdetect -y 1 || true
                '''
            }
        }

        stage('Unload Driver') {
            steps {
                sh '''
                    echo "===== UNLOAD DRIVER ====="
                    sudo rmmod i2c_dummy_driver || true
                '''
            }
        }

        stage('Collect Logs') {
            steps {
                sh '''
                    echo "===== COLLECT LOGS ====="
                    mkdir -p ${LOG_DIR}
                    dmesg | tail -100 > ${LOG_DIR}/dmesg.log
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'logs/*.log', fingerprint: true
        }
        failure {
            echo '❌ I2C validation failed'
        }
        success {
            echo '✅ I2C validation passed on Raspberry Pi'
        }
    }
}

