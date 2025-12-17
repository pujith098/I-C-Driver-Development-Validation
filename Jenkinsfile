pipeline {
    agent any

    environment {
        DRIVER_DIR = "driver"
        DTS_DIR = "dts"
        SCRIPTS_DIR = "scripts"
        LOG_DIR = "logs"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/pujith098/I-C-Driver-Development-Validation.git'
            }
        }

        stage('Build Driver') {
            steps {
                dir("${DRIVER_DIR}") {
                    sh '''
                    make clean
                    make
                    '''
                }
            }
        }

        stage('Build DT Overlay') {
            steps {
                dir("${DTS_DIR}") {
                    sh '''
                    dtc -I dts -O dtb -o i2c_dummy.dtbo i2c_dummy_overlay.dts
                    '''
                }
            }
        }

        stage('Load/Unload Test') {
            steps {
                dir("${SCRIPTS_DIR}") {
                    sh '''
                    # Ensure scripts are executable
                    chmod +x load_driver.sh unload_driver.sh

                    # Run load/unload
                    ./load_driver.sh
                    sleep 2
                    ./unload_driver.sh
                    '''
                }
            }
        }

        stage('Collect Logs') {
            steps {
                sh '''
                mkdir -p ${LOG_DIR}
                dmesg | tail -n 50 > ${LOG_DIR}/dmesg.log
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'logs/**', fingerprint: true
        }
        failure {
            echo "❌ Validation failed"
        }
        success {
            echo "✅ Driver validated successfully"
        }
    }
}

