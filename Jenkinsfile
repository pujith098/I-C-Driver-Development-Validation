pipeline {
    agent any

    environment {
        DRIVER_DIR  = "driver"
        DTS_DIR     = "dts"
        SCRIPTS_DIR = "scripts"
        LOG_DIR     = "logs"
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build Kernel Driver') {
            steps {
                dir("${DRIVER_DIR}") {
                    sh '''
                        echo "🔧 Cleaning build"
                        make clean || true

                        echo "🔧 Building kernel module"
                        make
                    '''
                }
            }
        }

        stage('Build Device Tree Overlay') {
            steps {
                dir("${DTS_DIR}") {
                    sh '''
                        echo "🌳 Building DT overlay"
                        dtc -I dts -O dtb -o i2c_dummy.dtbo i2c_dummy_overlay.dts
                    '''
                }
            }
        }

        stage('Load / Unload Driver Test') {
            steps {
                sh '''
                    echo "🚀 Running load/unload test"

                    chmod +x ${SCRIPTS_DIR}/load_driver.sh
                    chmod +x ${SCRIPTS_DIR}/unload_driver.sh

                    ${SCRIPTS_DIR}/load_driver.sh
                    sleep 2
                    ${SCRIPTS_DIR}/unload_driver.sh
                '''
            }
        }

        stage('Collect Kernel Logs') {
            steps {
                sh '''
                    mkdir -p ${LOG_DIR}
                    echo "📄 Collecting dmesg logs"
                    dmesg | tail -n 100 > ${LOG_DIR}/dmesg.log
                '''
            }
        }
    }

    post {
        success {
            echo "✅ I2C Driver Validation SUCCESS"
        }
        failure {
            echo "❌ I2C Driver Validation FAILED"
        }
        always {
            archiveArtifacts artifacts: 'logs/**', fingerprint: true
        }
    }
}

