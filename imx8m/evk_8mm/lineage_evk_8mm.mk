$(call inherit-product, device/fsl/imx8m/evk_8mm/evk_8mm.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_evk_8mm
