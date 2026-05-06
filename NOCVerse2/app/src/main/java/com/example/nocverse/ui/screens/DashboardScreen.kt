package com.example.nocverse.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun DashboardScreen() {

    var total by remember { mutableStateOf(5) }
    var pending by remember { mutableStateOf(3) }
    var approved by remember { mutableStateOf(1) }
    var declined by remember { mutableStateOf(1) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0B1220))
            .padding(16.dp)
    ) {

        Text(
            text = "Welcome back, Rahul!",
            color = Color.White,
            fontSize = 22.sp
        )

        Spacer(modifier = Modifier.height(16.dp))

        Row(
            horizontalArrangement = Arrangement.SpaceBetween,
            modifier = Modifier.fillMaxWidth()
        ) {
            StatCard("Total", total, Color.Blue)
            StatCard("Pending", pending, Color.Yellow)
            StatCard("Approved", approved, Color.Green)
            StatCard("Declined", declined, Color.Red)
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = {
                total++
                pending++
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("➕ New Application")
        }

        Spacer(modifier = Modifier.height(24.dp))

        Text("Recent Applications", color = Color.White, fontSize = 18.sp)

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn {
            items(3) {
                ApplicationCard()
            }
        }
    }
}

@Composable
fun StatCard(title: String, count: Int, color: Color) {
    Card(
        modifier = Modifier
            .width(80.dp)
            .height(80.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1A2238))
    ) {
        Column(
            modifier = Modifier.padding(8.dp),
            verticalArrangement = Arrangement.Center
        ) {
            Text("$count", color = color, fontSize = 20.sp)
            Text(title, color = Color.Gray, fontSize = 12.sp)
        }
    }
}

@Composable
fun ApplicationCard() {

    var status by remember { mutableStateOf("Pending") }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF111827))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {

            Text("NOC for Building", color = Color.White)

            Spacer(modifier = Modifier.height(8.dp))

            Row {
                Button(onClick = { status = "Approved" }) {
                    Text("Approve")
                }
                Spacer(modifier = Modifier.width(8.dp))
                Button(onClick = { status = "Declined" }) {
                    Text("Reject")
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            Text("Status: $status", color = Color.Green)
        }
    }
}