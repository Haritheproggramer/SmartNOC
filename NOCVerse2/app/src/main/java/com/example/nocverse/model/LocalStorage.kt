package com.example.nocverse.model

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object LocalStorage {

    private const val PREF_NAME = "nocverse_prefs"
    private const val KEY_APPS = "applications"

    fun saveApplication(context: Context, title: String, category: String, priority: String, description: String) {

        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(KEY_APPS, "[]")

        val jsonArray = JSONArray(existing)

        val obj = JSONObject().apply {
            put("title", title)
            put("category", category)
            put("priority", priority)
            put("description", description)
            put("status", "Pending")
        }

        jsonArray.put(obj)

        prefs.edit().putString(KEY_APPS, jsonArray.toString()).apply()
    }

    fun getApplications(context: Context): List<JSONObject> {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(KEY_APPS, "[]")

        val list = mutableListOf<JSONObject>()
        val jsonArray = JSONArray(json)

        for (i in 0 until jsonArray.length()) {
            list.add(jsonArray.getJSONObject(i))
        }

        return list
    }
}