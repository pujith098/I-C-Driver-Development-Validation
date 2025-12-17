// SPDX-License-Identifier: GPL-2.0
/*
 * Dummy I2C Platform Driver with Device Tree skeleton
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/of.h>

#define DRIVER_NAME "i2c_dummy_driver"

struct i2c_dummy_data {
    int dummy;
};

static int i2c_dummy_probe(struct platform_device *pdev)
{
    struct i2c_dummy_data *data;

    pr_info("%s: probe called\n", DRIVER_NAME);

    data = devm_kzalloc(&pdev->dev, sizeof(*data), GFP_KERNEL);
    if (!data)
        return -ENOMEM;

    platform_set_drvdata(pdev, data);

    pr_info("%s: platform device registered\n", DRIVER_NAME);

    return 0;
}

static void i2c_dummy_remove(struct platform_device *pdev)
{
    pr_info("%s: remove called\n", DRIVER_NAME);
}

static const struct of_device_id i2c_dummy_of_match[] = {
    { .compatible = "pujith,i2c-dummy", },
    { }
};
MODULE_DEVICE_TABLE(of, i2c_dummy_of_match);

static struct platform_driver i2c_dummy_platform_driver = {
    .probe  = i2c_dummy_probe,
    .remove = i2c_dummy_remove,
    .driver = {
        .name = DRIVER_NAME,
        .owner = THIS_MODULE,
        .of_match_table = i2c_dummy_of_match,
    },
};

static int __init i2c_dummy_init(void)
{
    pr_info("%s: init\n", DRIVER_NAME);
    return platform_driver_register(&i2c_dummy_platform_driver);
}

static void __exit i2c_dummy_exit(void)
{
    pr_info("%s: exit\n", DRIVER_NAME);
    platform_driver_unregister(&i2c_dummy_platform_driver);
}

module_init(i2c_dummy_init);
module_exit(i2c_dummy_exit);

MODULE_AUTHOR("Pujith");
MODULE_DESCRIPTION("Dummy I2C Platform Driver Skeleton with DT support");
MODULE_LICENSE("GPL");

