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
        LOG_DIR    = 'logs'
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                sh '''
                    mkdir -p logs/{build,integration,stress,fault,system}
                    scripts/setup_env.sh
                '''
            }
        }

        stage('Build Driver') {
            steps {
                sh '''
                    echo "===== BUILD DRIVER ====="
                    cd ${DRIVER_DIR}
                    make clean
                    make
                '''
            }
        }

        stage('Load Driver & Overlay') {
            steps {
                sh '''
                    echo "===== LOAD DRIVER ====="
                    scripts/load_driver.sh
                '''
            }
        }

        stage('Integration Tests') {
            steps {
                sh '''
                    tests/integration/test_probe.sh
                    tests/integration/test_write.sh
                    tests/integration/test_read.sh
                    tests/integration/test_rw_combined.sh
                '''
            }
        }

        stage('Stress Tests (10K Transfers)') {
            steps {
                sh '''
                    tests/stress/i2c_stress_rw.sh
                '''
            }
        }

        stage('Fault Injection Tests') {
            steps {
                sh '''
                    tests/fault/invalid_addr_test.sh
                    tests/fault/no_slave_test.sh
                '''
            }
        }

        stage('Unload Driver') {
            steps {
                sh '''
                    scripts/unload_driver.sh
                '''
            }
        }
    }

    post {
        always {
            sh '''
                scripts/collect_logs.sh
            '''
            archiveArtifacts artifacts: 'logs/**', fingerprint: true
        }

        success {
            echo '✅ I2C DRIVER VALIDATION PASSED (REAL HARDWARE)'
        }

        failure {
            echo '❌ I2C DRIVER VALIDATION FAILED'
        }
    }
}

