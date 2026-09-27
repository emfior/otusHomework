workspace "sandwich-store" "I'll Have the BLT: decomposition by business capability" {
    !impliedRelationships false

    model {
        customer = person "Покупатель" "Выбирает магазин, оформляет, оплачивает и получает заказ"
        manager = person "Управляющий" "Управляет своими магазинами и локальными акциями"
        networkAdmin = person "Администратор сети" "Управляет каталогом, франшизами, доступом и национальными акциями"
        employee = person "Сотрудник магазина" "Готовит и выдаёт заказы, учитывает наличные"
        courier = person "Курьер" "Доставляет назначенные заказы, учитывает оплату при получении"

        paymentProvider = softwareSystem "Payment Provider" "Внешняя система онлайн-оплаты и возвратов" "External"
        mappingProviderA = softwareSystem "Mapping Provider A" "Внешняя система маршрутов и дорожной ситуации" "External"
        mappingProviderB = softwareSystem "Mapping Provider B" "Альтернативная внешняя система маршрутов и пробок" "External"

        sandwichStore = softwareSystem "Sandwich Store" "Онлайн-заказы сети сэндвичных с независимыми франшизами" {
            webApplication = container "Web Application" "Адаптивный UI и BFF для всех ролей; защищённая сессия" "Server-side Web, HTML/CSS/JavaScript"
            identityService = container "Identity Service" "Учётные записи, вход, роли и доступ к магазинам" "OIDC/OAuth 2.0, JWT" "Service"
            productService = container "Product Service" "Каталог, меню магазина, базовые цены, доступность и расчёт товаров" "Java / Spring Boot" "Service"
            franchiseService = container "Franchise Service" "Магазины, расписания, настройки, национальные и локальные акции" "Java / Spring Boot" "Service"
            orderService = container "Order Service" "Корзина, оформление, очередь кухни, готовность и состояние заказа" "Java / Spring Boot" "Service"
            billingService = container "Billing Service" "Онлайн-платежи, учёт наличных, попытки и полные возвраты" "Java / Spring Boot" "Service"
            deliveryService = container "Delivery Service" "Зона и тариф доставки, назначение курьера, забор и вручение" "Java / Spring Boot" "Service"
            mapService = container "Map Service" "Маршруты с пробками; выбор и переключение внешних провайдеров" "Java / Spring Boot" "Service"

            identityDatabase = container "Identity Database" "Аккаунты, сессии, роли и назначения магазинов" "PostgreSQL" "Database"
            productDatabase = container "Product Database" "Каталог, меню, цены, доступность, расчёты" "PostgreSQL" "Database"
            franchiseDatabase = container "Franchise Database" "Магазины, владельцы, настройки, акции" "PostgreSQL" "Database"
            orderDatabase = container "Order Database" "Корзины, предложения, заказы, снимки, очередь кухни, outbox/inbox" "PostgreSQL" "Database"
            billingDatabase = container "Billing Database" "Платежи, попытки, наличные, возвраты, outbox/inbox" "PostgreSQL" "Database"
            deliveryDatabase = container "Delivery Database" "Доставки, курьеры, назначения, расчёты, outbox/inbox" "PostgreSQL" "Database"

            webApplication -> identityService "Регистрация, вход, роли, JWKS" "HTTPS / OIDC, JSON"
            webApplication -> productService "Меню и управление ассортиментом" "HTTPS / JSON"
            webApplication -> franchiseService "Магазины, настройки и акции" "HTTPS / JSON"
            webApplication -> orderService "Корзина, оформление и работа кухни" "HTTPS / JSON"
            webApplication -> billingService "Статус платежа, учёт наличных и их возврата в магазине" "HTTPS / JSON"
            webApplication -> deliveryService "Курьер, доставка, маршрут и наличные при вручении" "HTTPS / JSON"
            webApplication -> mapService "Маршрут покупателя до магазина" "HTTPS / JSON"

            productService -> identityService "Обновляет кеш публичных ключей JWT" "HTTPS / JWKS" "Security"
            franchiseService -> identityService "Обновляет кеш публичных ключей JWT" "HTTPS / JWKS" "Security"
            orderService -> identityService "Обновляет кеш публичных ключей JWT" "HTTPS / JWKS" "Security"
            billingService -> identityService "Обновляет кеш публичных ключей JWT" "HTTPS / JWKS" "Security"
            deliveryService -> identityService "Обновляет кеш публичных ключей JWT" "HTTPS / JWKS" "Security"
            mapService -> identityService "Обновляет кеш публичных ключей JWT" "HTTPS / JWKS" "Security"

            identityService -> identityDatabase "Читает и записывает" "SQL / TLS"
            productService -> productDatabase "Читает и записывает" "SQL / TLS"
            franchiseService -> franchiseDatabase "Читает и записывает" "SQL / TLS"
            orderService -> orderDatabase "Читает и записывает" "SQL / TLS"
            billingService -> billingDatabase "Читает и записывает" "SQL / TLS"
            deliveryService -> deliveryDatabase "Читает и записывает" "SQL / TLS"

            orderService -> productService "Стоимость товаров и проверка доступности" "HTTPS / JSON"
            orderService -> franchiseService "Приём заказов, способы оплаты, параметры кухни" "HTTPS / JSON"
            orderService -> billingService "Создание, сверка платежа и повтор оплаты" "HTTPS / JSON"
            orderService -> deliveryService "Тариф и проверка зоны доставки" "HTTPS / JSON"
            productService -> franchiseService "Магазин, валюта и применение акции" "HTTPS / JSON"
            deliveryService -> franchiseService "Адрес магазина, зона и тариф" "HTTPS / JSON"
            deliveryService -> mapService "Маршрут курьера" "HTTPS / JSON"
            deliveryService -> billingService "Фиксирует наличные от назначенного курьера" "HTTPS / JSON"
            mapService -> franchiseService "Координаты магазина для самовывоза" "HTTPS / JSON"

            orderService -> billingService "OrderCancelled via RabbitMQ" "AMQP / TLS, JSON v1" "Async"
            orderService -> deliveryService "OrderConfirmed, OrderReady, OrderCancelled via RabbitMQ" "AMQP / TLS, JSON v1" "Async"
            billingService -> orderService "PaymentSucceeded, PaymentFailed, RefundStatusChanged via RabbitMQ" "AMQP / TLS, JSON v1" "Async"
            billingService -> deliveryService "PaymentSucceeded via RabbitMQ" "AMQP / TLS, JSON v1" "Async"
            deliveryService -> orderService "DeliveryAssigned, DeliveryAssignmentFailed, DeliveryPickedUp, DeliveryDelivered, DeliveryFailed, DeliveryCancelled via RabbitMQ" "AMQP / TLS, JSON v1" "Async"
        }

        customer -> sandwichStore "Оформляет и получает заказ"
        manager -> sandwichStore "Управляет своими магазинами"
        networkAdmin -> sandwichStore "Управляет сетью"
        employee -> sandwichStore "Готовит и выдаёт заказы"
        courier -> sandwichStore "Выполняет доставку"
        sandwichStore -> paymentProvider "Онлайн-платежи и возвраты" "HTTPS"
        paymentProvider -> sandwichStore "Подтверждения платежей и возвратов" "HTTPS callbacks"
        sandwichStore -> mappingProviderA "Маршруты с пробками" "HTTPS"
        sandwichStore -> mappingProviderB "Маршруты с пробками / резерв" "HTTPS"

        customer -> webApplication "Выбирает, заказывает и отслеживает" "HTTPS"
        manager -> webApplication "Настраивает магазин и локальные акции" "HTTPS"
        networkAdmin -> webApplication "Управляет каталогом, сетью и ролями" "HTTPS"
        employee -> webApplication "Управляет приготовлением и выдачей" "HTTPS"
        courier -> webApplication "Получает и выполняет назначения" "HTTPS"
        billingService -> paymentProvider "Создаёт платёж, сверяет, отменяет и возвращает" "HTTPS / Provider API"
        paymentProvider -> billingService "Подписанные callbacks платежей и возвратов" "HTTPS / JSON"
        mapService -> mappingProviderA "Запрашивает маршрут и дорожную ситуацию" "HTTPS / Provider API"
        mapService -> mappingProviderB "Запрашивает маршрут при выборе региона / отказе A" "HTTPS / Provider API"
    }

    views {
        systemContext sandwichStore "SystemContext" "Контекст системы" {
            include *
            autoLayout lr
        }
        container sandwichStore "Containers" "C4: все приложения, хранилища и внешние системы" {
            include *
            autoLayout lr
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
                background #315C85
            }
            element "External" {
                background #666666
                color #ffffff
            }
            relationship "Relationship" {
                routing Orthogonal
                fontSize 16
                dashed false
            }
            relationship "Async" {
                dashed true
                color #A34A00
            }
            relationship "Security" {
                color #999999
            }
        }
    }
}
