package com.example.nocverse.ui

import androidx.compose.runtime.Composable
import androidx.navigation.compose.*
import com.example.nocverse.ui.screens.*

@Composable
fun AppNavigation() {
    val navController = rememberNavController()

    NavHost(navController, startDestination = "dashboard") {

        composable("dashboard") {
            DashboardScreen(navController)
        }
        composable("notifications") {
            NotificationScreen()
        }
        composable("new_application") {
            NewApplicationScreen(navController)
        }
    }
}