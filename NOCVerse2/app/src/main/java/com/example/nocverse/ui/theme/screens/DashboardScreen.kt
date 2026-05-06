package com.example.nocverse.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.compose.ui.platform.LocalContext
import com.example.nocverse.model.*
@Composable
fun DashboardScreen(navController: NavController) {
    val context = LocalContext.current
    var applications by remember { mutableStateOf(listOf<org.json.JSONObject>()) }

    LaunchedEffect(Unit) {
        applications = LocalStorage.getApplications(context)
    }
    val context = LocalContext.current
    val db = AppDatabase.getDatabase(context)

    var applications by remember { mutableStateOf(listOf<ApplicationEntity>()) }

    LaunchedEffect(Unit) {
        applications = db.applicationDao().getAll()
    }
    Row(modifier = Modifier.fillMaxSize()) {

        // SIDEBAR
        Column(
            modifier = Modifier
                .width(200.dp)
                .fillMaxHeight()
                .background(Color(0xFF0F172A))
                .padding(16.dp)
        ) {
            Text("NOCVerse", color = Color.White, fontSize = 20.sp)

            Spacer(modifier = Modifier.height(24.dp))

            SidebarItem("Dashboard") {
                navController.navigate("dashboard")
            }

            SidebarItem("Create Application") {
                navController.navigate("new_application")
            }

            SidebarItem("My Applications") {}
            SidebarItem("Notifications") {
                navController.navigate("notifications")
            }
        }

        // MAIN CONTENT
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF0B1220))
                .padding(16.dp)
        ) {

            Text("Welcome back!", color = Color.White, fontSize = 22.sp)

            Spacer(modifier = Modifier.height(16.dp))

            Row(horizontalArrangement = Arrangement.SpaceBetween) {
                StatCard("Total", 5, Color.Blue)
                StatCard("Pending", 3, Color.Yellow)
                StatCard("Approved", 1, Color.Green)
                StatCard("Declined", 1, Color.Red)
            }

            Spacer(modifier = Modifier.height(20.dp))

            Button(
                onClick = { navController.navigate("new_application") }
            ) {
                Text("➕ New Application")
            }

            Spacer(modifier = Modifier.height(20.dp))

            LazyColumn {
                ->
                items(applications.size) { index ->
                    val app = applications[index]

                    ApplicationCardData(
                        title = app.getString("title"),
                        status = app.getString("status")
                    )
                }
            }
            }
        }
    }

@Composable
fun SidebarItem(title: String, onClick: () -> Unit) {
    Text(
        text = title,
        color = Color.White,
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp)
            .clickable { onClick() }
    )
}
@Composable
fun StatCard(title: String, count: Int, color: Color) {
    Card(
        modifier = Modifier
            .width(90.dp)
            .height(90.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1A2238))
    ) {
        Column(modifier = Modifier.padding(10.dp)) {
            Text("$count", color = color)
            Text(title, color = Color.Gray)
        }
    }
}

@Composable
fun ApplicationCardData(title: String, status: String) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF111827))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, color = Color.White)
            Text("Status: $status", color = Color.Yellow)
        }
    }
}
@Composable
fun ApplicationCardData(app: ApplicationEntity) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF111827))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(app.title, color = Color.White)
            Text("Status: ${app.status}", color = Color.Yellow)
        }
    }
}