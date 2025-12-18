pipeline {
    agent {
        label 'raspberrypi'
    }

    options {
        timestamps()
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
                    echo "===== SETUP ENV ====="
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
                    echo "===== INTEGRATION TESTS ====="
                    tests/integration/test_probe.sh
                    tests/integration/test_write.sh
                    tests/integration/test_read.sh
                    tests/integration/test_rw_combined.sh
                '''
            }
        }

        stage('Stress Tests (10K RW)') {
            steps {
                sh '''
                    echo "===== STRESS TESTS ====="
                    tests/stress/i2c_stress_rw.sh
                '''
            }
        }

        stage('Fault Injection Tests') {
            steps {
                sh '''
                    echo "===== FAULT TESTS ====="
                    tests/fault/invalid_addr_test.sh
                    tests/fault/no_slave_test.sh
                '''
            }
        }

        stage('Unload Driver') {
            steps {
                sh '''
                    echo "===== UNLOAD DRIVER ====="
                    scripts/unload_driver.sh
                '''
            }
        }
    }

    post {
        always {
            sh '''
                echo "===== COLLECT LOGS ====="
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

