
#include <linux/delay.h>
#include <linux/dmaengine.h>
#include <linux/init.h>
#include <linux/kthread.h>
#include <linux/module.h>
#include <linux/of_dma.h>
#include <linux/platform_device.h>
#include <linux/random.h>
#include <linux/slab.h>
#include <linux/wait.h>
#include <linux/amba/xilinx_dma.h>




int probe2(struct platform_device *pdev)
{
    pr_info("Starting DMA test...\n");
	return 0;
}

int remove2(struct platform_device *pdev)
{
    pr_info("Stopping DMA test...\n");
	return 0;
}

static const struct of_device_id test_of_ids[] = {
	{ .compatible = "caccabubbola"},
	{}
};

static struct platform_driver test_driver = {
	.driver = {
		.name = "dtb_try_bind",
		.owner = THIS_MODULE,
		.of_match_table = test_of_ids,
	},
	.probe = probe2,
	.remove = remove2,
};

static int __init trybind_init(void)
{
    pr_info("loading trybind driver\n");
	return platform_driver_register(&test_driver);

}
late_initcall(trybind_init);

static void __exit trybind_exit(void)
{
    pr_info("removing trybind driver\n");
	platform_driver_unregister(&test_driver);
}
module_exit(trybind_exit)

MODULE_AUTHOR("Andrea Rigoni");
MODULE_DESCRIPTION("Try to bind to a dtb device");
MODULE_LICENSE("GPL v2");
