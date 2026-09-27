
workspace "sandwich-store"  {
    
    model {
        user = person "User" "A user of the system"
        courier = person "Courier" "A user of the system"
        director = person "Director" "A user of the system"
        employee = person "Employee" "A store employee"

        softwareSystem = softwareSystem "sandwich-store" "Online sandwich store" {
            webApplication = container "Web Application" "Delivers the customer and staff UI" "Technology"
            identityService = container "Identity Service" "Registration and authentication" "Technology"
            billingService = container "Billing Service" "Payment management" "Technology"
            orderService = container "Order Service" "Order state" "Technology"
            mapService = container "Map Service" "Route building" "Technology"
            productService = container "Product Service" "Getting info about products and categories" "Technology"
            deliveryService = container "Delivery Service" "Delivery management" "Technology"
            franchiseService = container "Franchise Service" "Store management" "Technology"

            identityDatabase = container "Identity Database" "Accounts and credentials" "Technology" "Database"
            orderDatabase = container "Order Database" "order state" "Technology" "Database"
            billingDatabase = container "Billing Database" "payment state and price" "Technology" "Database"
            productDatabase = container "Product Database" "kinds of product" "Technology" "Database"
            deliveryDatabase = container "Delivery Database" "delivery state" "Technology" "Database"
            franchiseDatabase = container "Franchise Database" "special offers, plans, store common info" "Technology" "Database"

            webApplication -> identityService "Registers users and signs users in"
            webApplication -> franchiseService "Shows stores, schedules and promotions"
            webApplication -> productService "Shows menu, prices and availability"
            webApplication -> orderService "Manages carts, orders and statuses"
            webApplication -> billingService "Starts and confirms payments"
            webApplication -> deliveryService "Shows delivery options and delivery status"
            webApplication -> mapService "Shows pickup and delivery routes"

            identityService -> identityDatabase "Reads from and writes to"
            orderService -> orderDatabase "Reads from and writes to"
            billingService -> billingDatabase "Reads from and writes to"
            productService -> productDatabase "Uses"
            deliveryService -> deliveryDatabase "Reads from and writes to"
            franchiseService -> franchiseDatabase "Reads from and writes to"

            orderService -> identityService "Validates customer, staff and courier accounts"
            orderService -> productService "Checks items, prices and availability"
            orderService -> franchiseService "Gets store info, promotions and preparation rules"
            orderService -> billingService "Requests payment calculation and status"
            orderService -> deliveryService "Creates delivery requests"

            billingService -> productService "Gets product prices"
            billingService -> franchiseService "Gets promotion rules"
            billingService -> orderService "Notifies about payment status"

            deliveryService -> orderService "Gets delivery order details and updates delivery status"
            deliveryService -> franchiseService "Gets store address and delivery conditions"
            deliveryService -> mapService "Builds courier routes"

            mapService -> franchiseService "Gets store address"
            productService -> franchiseService "Gets store-specific assortment and local promotions"

        }
        
        user -> softwareSystem "Uses"
        courier -> softwareSystem "Uses"
        director -> softwareSystem "Uses"
        employee -> softwareSystem "Uses"

        user -> webApplication "Uses"
        courier -> webApplication "Uses"
        director -> webApplication "Uses"
        employee -> webApplication "Uses"
    }
    
    views {
        systemContext softwareSystem "SystemContext" {
            include *
            autoLayout
        }
        
        container softwareSystem "Containers" {
            include *
            autoLayout
        }
        
        styles {
            element "Person" {
                shape Person
                background #08427B
                color #ffffff
            }
            element "Software System" {
                background #1168BD
                color #ffffff
            }
            element "Container" {
                background #438DD5
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
        }
    }
}
