ruleset manage_fleet {
	meta {
		name "manage fleet"
		description << part one of the multiple pico lab >>
		author "Andrew Manwaring"
		logging on
		sharing on
		provides vehicles
		provides subscriptions
		use module a169x625 alias CloudOS
	}
	global{
		vehicles = function() {
			results = wranglerOS:children();
			children = results{"children"};
			children
		};

		subscriptions = function() {
			allSubscriptions = CloudOS:getAllSubscriptions();
			allSubscriptions
		};
	}
	rule create_vehicle {
		select when car new_vehicle
		pre {
			attributes = {}
				.put(["Prototype_rids"],"b507764x4.prod;b507764x5.prod;b507764x7.prod") //track_trips_part_2;trip_store;subscription_request
				.put(["name"],event:attr("vehicle_name"))
				.put(["parent_eci"], "7AC39FAE-F6A9-11E5-BE21-84E6E71C24E1")
				;
		}
		{
			event:send({"cid":meta:eci()}, "wrangler", "child_creation")
				with attrs = attributes.klog("attributes: ");
		}
		always {
			log("create child for " + child);
		}
	}
	rule autoAccept {
		select when wrangler inbound_pending_subscription_added
		pre {
			attributes = event:attrs().klog("subscription: ");
		}
		{
			noop();
		}
		always {
			raise wrangler event "pending_subscription_approval"
				attributes attributes;
				log("auto accepted subscription.")
		}
	}
}