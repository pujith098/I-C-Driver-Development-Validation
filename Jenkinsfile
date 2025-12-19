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
        PATH      = "${env.PATH}:/usr/sbin:/sbin"  // Ensure i2cdetect is visible
        I2C_BUS   = '/dev/i2c-1'                   // Default I2C bus on Raspberry Pi
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
                    export PATH=$PATH:/usr/sbin:/sbin
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
                    export PATH=$PATH:/usr/sbin:/sbin
                    # Provide I2C bus explicitly to all probe tests
                    tests/integration/test_probe.sh ${I2C_BUS}
                    tests/integration/test_write.sh ${I2C_BUS}
                    tests/integration/test_read.sh ${I2C_BUS}
                    tests/integration/test_rw_combined.sh ${I2C_BUS}
                '''
            }
        }

        stage('Stress Tests (10K RW)') {
            steps {
                sh '''
                    echo "===== STRESS TESTS ====="
                    export PATH=$PATH:/usr/sbin:/sbin
                    tests/stress/i2c_stress_rw.sh ${I2C_BUS}
                '''
            }
        }

        stage('Fault Injection Tests') {
            steps {
                sh '''
                    echo "===== FAULT TESTS ====="
                    export PATH=$PATH:/usr/sbin:/sbin
                    tests/fault/invalid_addr_test.sh ${I2C_BUS}
                    tests/fault/no_slave_test.sh ${I2C_BUS}
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

