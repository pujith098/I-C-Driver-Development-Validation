/**
 * I2C LCD 2004A Driver with Industrial Validation Support
 * Authors: Pujit, Sneha
 * Version: 2.0
 */

#include <linux/module.h>
#include <linux/i2c.h>
#include <linux/of.h>
#include <linux/delay.h>
#include <linux/slab.h>
#include <linux/device.h>
#include <linux/sysfs.h>
#include <linux/mutex.h>

#define DRIVER_NAME "i2c_lcd_2004a"
#define LCD_MAX_RETRY 3

struct lcd_device {
    struct i2c_client *client;
    struct mutex lock;
    u8 display_state;
    unsigned int tx_count;
    unsigned int rx_count;
    unsigned int error_count;
};

static int lcd_send_cmd_retry(struct lcd_device *lcd, u8 cmd)
{
    int ret, retry;
    
    for (retry = 0; retry < LCD_MAX_RETRY; retry++) {
        ret = i2c_smbus_write_byte(lcd->client, cmd);
        if (ret == 0) {
            lcd->tx_count++;
            return 0;
        }
        msleep(10);
    }
    lcd->error_count++;
    return ret;
}

static int lcd_init_sequence(struct lcd_device *lcd)
{
    int ret;
    dev_info(&lcd->client->dev, "Starting LCD init\n");
    msleep(50);
    
    ret = lcd_send_cmd_retry(lcd, 0x33);
    if (ret) return ret;
    msleep(5);
    
    ret = lcd_send_cmd_retry(lcd, 0x32);
    if (ret) return ret;
    msleep(5);
    
    ret = lcd_send_cmd_retry(lcd, 0x28);
    if (ret) return ret;
    msleep(1);
    
    ret = lcd_send_cmd_retry(lcd, 0x0C);
    if (ret) return ret;
    lcd->display_state = 1;
    msleep(1);
    
    ret = lcd_send_cmd_retry(lcd, 0x06);
    if (ret) return ret;
    msleep(1);
    
    ret = lcd_send_cmd_retry(lcd, 0x01);
    if (ret) return ret;
    msleep(2);
    
    dev_info(&lcd->client->dev, "LCD initialization completed\n");
    return 0;
}

static ssize_t clear_display_store(struct device *dev,
                                    struct device_attribute *attr,
                                    const char *buf, size_t count)
{
    struct lcd_device *lcd = dev_get_drvdata(dev);
    int ret;
    mutex_lock(&lcd->lock);
    ret = lcd_send_cmd_retry(lcd, 0x01);
    mutex_unlock(&lcd->lock);
    return ret < 0 ? ret : count;
}
static DEVICE_ATTR_WO(clear_display);

static ssize_t stats_show(struct device *dev,
                          struct device_attribute *attr,
                          char *buf)
{
    struct lcd_device *lcd = dev_get_drvdata(dev);
    return sprintf(buf, "TX: %u\nRX: %u\nErrors: %u\n",
                   lcd->tx_count, lcd->rx_count, lcd->error_count);
}
static DEVICE_ATTR_RO(stats);

static ssize_t display_control_store(struct device *dev,
                                      struct device_attribute *attr,
                                      const char *buf, size_t count)
{
    struct lcd_device *lcd = dev_get_drvdata(dev);
    int ret;
    u8 cmd;
    
    if (strncmp(buf, "on", 2) == 0) {
        cmd = 0x0C;
        lcd->display_state = 1;
    } else if (strncmp(buf, "off", 3) == 0) {
        cmd = 0x08;
        lcd->display_state = 0;
    } else {
        return -EINVAL;
    }
    
    mutex_lock(&lcd->lock);
    ret = lcd_send_cmd_retry(lcd, cmd);
    mutex_unlock(&lcd->lock);
    return ret < 0 ? ret : count;
}

static ssize_t display_control_show(struct device *dev,
                                     struct device_attribute *attr,
                                     char *buf)
{
    struct lcd_device *lcd = dev_get_drvdata(dev);
    return sprintf(buf, "%s\n", lcd->display_state ? "on" : "off");
}
static DEVICE_ATTR_RW(display_control);

static struct attribute *lcd_attrs[] = {
    &dev_attr_clear_display.attr,
    &dev_attr_stats.attr,
    &dev_attr_display_control.attr,
    NULL,
};

static const struct attribute_group lcd_attr_group = {
    .attrs = lcd_attrs,
};

static int lcd_probe(struct i2c_client *client)
{
    struct lcd_device *lcd;
    int ret;
    
    dev_info(&client->dev, "2004A LCD detected at 0x%02x\n", client->addr);
    
    lcd = devm_kzalloc(&client->dev, sizeof(*lcd), GFP_KERNEL);
    if (!lcd)
        return -ENOMEM;
    
    lcd->client = client;
    mutex_init(&lcd->lock);
    i2c_set_clientdata(client, lcd);
    
    ret = i2c_smbus_write_byte(client, 0x00);
    if (ret < 0) {
        dev_err(&client->dev, "I2C test failed: %d\n", ret);
        return ret;
    }
    
    ret = lcd_init_sequence(lcd);
    if (ret < 0)
        return ret;
    
    ret = sysfs_create_group(&client->dev.kobj, &lcd_attr_group);
    if (ret)
        return ret;
    
    dev_info(&client->dev, "LCD init done (sysfs: /sys/bus/i2c/devices/%d-%04x/)\n",
             client->adapter->nr, client->addr);
    
    return 0;
}

static void lcd_remove(struct i2c_client *client)
{
    struct lcd_device *lcd = i2c_get_clientdata(client);
    
    sysfs_remove_group(&client->dev.kobj, &lcd_attr_group);
    
    mutex_lock(&lcd->lock);
    lcd_send_cmd_retry(lcd, 0x01);
    lcd_send_cmd_retry(lcd, 0x08);
    mutex_unlock(&lcd->lock);
    
    dev_info(&client->dev, "LCD removed (TX:%u Errors:%u)\n",
             lcd->tx_count, lcd->error_count);
}

static const struct of_device_id lcd_of_match[] = {
    { .compatible = "custom,i2c-lcd-2004a" },
    { }
};
MODULE_DEVICE_TABLE(of, lcd_of_match);

static const struct i2c_device_id lcd_id[] = {
    { "i2c_lcd_2004a", 0 },
    { }
};
MODULE_DEVICE_TABLE(i2c, lcd_id);

static struct i2c_driver lcd_driver = {
    .driver = {
        .name = DRIVER_NAME,
        .of_match_table = lcd_of_match,
    },
    .probe  = lcd_probe,
    .remove = lcd_remove,
    .id_table = lcd_id,
};

module_i2c_driver(lcd_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Pujit, Sneha");
MODULE_DESCRIPTION("I2C LCD 2004A Driver");
MODULE_VERSION("2.0");
