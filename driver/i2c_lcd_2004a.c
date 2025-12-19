#include <linux/module.h>
#include <linux/i2c.h>
#include <linux/of.h>
#include <linux/delay.h>

#define DRIVER_NAME "i2c_lcd_2004a"

static int lcd_send_cmd(struct i2c_client *client, u8 cmd)
{
    return i2c_smbus_write_byte(client, cmd);
}

static int lcd_probe(struct i2c_client *client)
{
    dev_info(&client->dev, "2004A LCD detected at 0x%02x\n", client->addr);

    /* Basic init sequence */
    msleep(50);
    lcd_send_cmd(client, 0x33);
    lcd_send_cmd(client, 0x32);
    lcd_send_cmd(client, 0x28);
    lcd_send_cmd(client, 0x0C);
    lcd_send_cmd(client, 0x06);
    lcd_send_cmd(client, 0x01);

    dev_info(&client->dev, "LCD initialization done\n");
    return 0;
}

static void lcd_remove(struct i2c_client *client)
{
    dev_info(&client->dev, "LCD removed\n");
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

