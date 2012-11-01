#!/bin/bash

# Source in configuration file
if [[ -f openstack.conf ]]
then
        . openstack.conf
else
        echo "Configuration file not found. Please create openstack.conf"
        exit 1
fi

get_id() {
	echo `$@ | awk '/ id / { print $4 }'`
}

# Get admin tenant id
TENANT_ID=$(keystone tenant-list | awk '/ admin / { print $2}')

##########################################################
#
# Create Private Network
#
# Create the named network for the admin tenant
TENANT_NET_ID=$(get_id quantum net-create --tenant_id $TENANT_ID ${TENANT_NETWORK_NAME})

# Create the private network range in this named network
SUBNET_ID=$(get_id quantum subnet-create --tenant_id ${TENANT_ID} --ip_version 4 ${TENANT_NET_ID} ${PRIV_CIDR} --gateway_ip ${PRIV_GW})

# Create a private router for this tenant
ROUTER_ID=$(get_id quantum router-create --tenant_id ${TENANT_ID} provider-router)

# Create an interface on the router
quantum router-interface-add ${ROUTER_ID} ${SUBNET_ID}



###########################################################
#
# Create External Network (${EXTERNAL_NETWORK_NAME})
#

# Create external network
#EXT_NET_ID=$(get_id quantum net-create ${EXTERNAL_NETWORK_NAME} -- --router:external=True)

# Create Floating IP Range
#quantum subnet-create --ip_version 4 --allocation-pool start=${FLOAT_START},end=${FLOAT_END} --gateway ${FLOAT_GATEWAY} ${EXT_NET_ID} ${EXT_CIDR} -- --enable_dhcp=False

# Set the gateway for the router
#quantum router-gateway-set ${ROUTER_ID} ${EXT_NET_ID}

# Create floating IP for ${EXTERNAL_NETWORK_NAME}
#quantum floatingip-create ${EXTERNAL_NETWORK_NAME}
