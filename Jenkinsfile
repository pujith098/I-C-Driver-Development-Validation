pipeline {
    agent {
        label 'raspberrypi'
    }

    options {
        timestamps()
        ansiColor('xterm')
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
                    echo "Kernel version:"
                    uname -a

                    echo "I2C devices:"
                    ls -l /dev/i2c* || true
                '''
            }
        }

        stage('Build I2C Driver') {
            steps {
                sh '''
                    cd ${DRIVER_DIR}
                    make clean || true
                    make
                '''
            }
        }

        stage('Load Driver') {
            steps {
                sh '''
                    sudo rmmod i2c_dummy_driver 2>/dev/null || true
                    sudo insmod driver/i2c_dummy_driver.ko
                    dmesg | tail -20
                '''
            }
        }

        stage('I2C Detect') {
            steps {
                sh '''
                    i2cdetect -y 1 || true
                '''
            }
        }

        stage('Unload Driver') {
            steps {
                sh '''
                    sudo rmmod i2c_dummy_driver || true
                '''
            }
        }

        stage('Collect Logs') {
            steps {
                sh '''
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
            echo '❌ Build failed – check driver or hardware'
        }
        success {
            echo '✅ I2C driver validation passed on Raspberry Pi'
        }
    }
}

