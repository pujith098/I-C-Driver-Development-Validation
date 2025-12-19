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
                    mkdir -p ${LOG_DIR}/{build,integration,stress,fault,system}
                    export PATH=$PATH:/usr/sbin:/sbin
                    scripts/setup_env.sh 2>&1 | tee ${LOG_DIR}/system/setup.log
                '''
            }
        }

        stage('Build Driver') {
            steps {
                sh '''
                    echo "===== BUILD DRIVER ====="
                    cd ${DRIVER_DIR}
                    mkdir -p ../logs/build
                    make clean 2>&1 | tee ../logs/build/make_clean.log
                    make 2>&1 | tee ../logs/build/make_build.log
                '''
            }
        }

        stage('Load Driver & Overlay') {
            steps {
                sh '''
                    echo "===== LOAD DRIVER ====="
                    mkdir -p ${LOG_DIR}/system
                    scripts/load_driver.sh 2>&1 | tee ${LOG_DIR}/system/load_driver.log
                '''
            }
        }

        stage('Integration Tests') {
            steps {
                sh '''
                    echo "===== INTEGRATION TESTS ====="
                    mkdir -p ${LOG_DIR}/integration
                    export PATH=$PATH:/usr/sbin:/sbin
                    tests/integration/test_probe.sh ${I2C_BUS} 2>&1 | tee ${LOG_DIR}/integration/test_probe.log
                    tests/integration/test_write.sh ${I2C_BUS} 2>&1 | tee ${LOG_DIR}/integration/test_write.log
                    tests/integration/test_read.sh ${I2C_BUS} 2>&1 | tee ${LOG_DIR}/integration/test_read.log
                    tests/integration/test_rw_combined.sh ${I2C_BUS} 2>&1 | tee ${LOG_DIR}/integration/test_rw_combined.log
                '''
            }
        }

        stage('Stress Tests (10K RW)') {
            steps {
                sh '''
                    echo "===== STRESS TESTS ====="
                    mkdir -p ${LOG_DIR}/stress
                    export PATH=$PATH:/usr/sbin:/sbin
                    tests/stress/i2c_stress_rw.sh ${I2C_BUS} 2>&1 | tee ${LOG_DIR}/stress/i2c_stress_rw.log
                '''
            }
        }

        stage('Fault Injection Tests') {
            steps {
                sh '''
                    echo "===== FAULT TESTS ====="
                    mkdir -p ${LOG_DIR}/fault
                    export PATH=$PATH:/usr/sbin:/sbin
                    tests/fault/invalid_addr_test.sh ${I2C_BUS} 2>&1 | tee ${LOG_DIR}/fault/invalid_addr_test.log
                    tests/fault/no_slave_test.sh ${I2C_BUS} 2>&1 | tee ${LOG_DIR}/fault/no_slave_test.log
                '''
            }
        }

        stage('Unload Driver') {
            steps {
                sh '''
                    echo "===== UNLOAD DRIVER ====="
                    mkdir -p ${LOG_DIR}/system
                    scripts/unload_driver.sh 2>&1 | tee ${LOG_DIR}/system/unload_driver.log
                '''
            }
        }
    }

    post {
        always {
            echo "===== COLLECT LOGS ====="
            sh '''
                scripts/collect_logs.sh 2>&1 | tee ${LOG_DIR}/system/collect_logs.log
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

