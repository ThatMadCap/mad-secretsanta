local function createTables()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `secretsanta_groups` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `creator_citizenid` VARCHAR(50) NOT NULL,
            `group_name` VARCHAR(100) NOT NULL UNIQUE,
            `status` ENUM('creating', 'ready') NOT NULL DEFAULT 'creating',
            `use_gift_list` BOOLEAN NOT NULL DEFAULT 0,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_creator` (`creator_citizenid`),
            INDEX `idx_status` (`status`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `secretsanta_members` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `group_id` INT NOT NULL,
            `citizen_id` VARCHAR(50) NOT NULL,
            `assigned_to_citizen_id` VARCHAR(50) DEFAULT NULL,
            `assigned_gift` VARCHAR(255) DEFAULT NULL,
            `is_creator` BOOLEAN NOT NULL DEFAULT 0,
            `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (`group_id`) REFERENCES `secretsanta_groups`(`id`) ON DELETE CASCADE,
            INDEX `idx_group_id` (`group_id`),
            INDEX `idx_citizen_id` (`citizen_id`),
            UNIQUE KEY `unique_member` (`group_id`, `citizen_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
end

CreateThread(function()
    createTables()
end)
