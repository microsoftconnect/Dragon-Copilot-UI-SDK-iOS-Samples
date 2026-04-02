/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

package com.microsoft.dragoncopilot.dependencytestapp.network

import com.microsoft.dragoncopilot.turnkey.BuildConfig
import com.microsoft.dragoncopilot.turnkey.logging.Logger.logError
import com.microsoft.dragoncopilot.turnkey.logging.Logger.logVerbose
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.HttpRequestRetry
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.auth.Auth
import io.ktor.client.plugins.auth.providers.BearerTokens
import io.ktor.client.plugins.auth.providers.bearer
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.statement.HttpResponse
import io.ktor.http.isSuccess
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

object NetworkClientProvider {
    val logLevel = if (BuildConfig.DEBUG) LogLevel.ALL else LogLevel.NONE

    fun getClient(authToken: String? = null, engine: HttpClientEngine = OkHttp.create()) = HttpClient(engine) {
        followRedirects = false
        install(ContentNegotiation) {
            json(
                Json {
                    ignoreUnknownKeys = true
                    isLenient = true
                    prettyPrint = true
                    encodeDefaults = true
                }
            )
        }

        install(HttpTimeout) {
            val timeout = 30_000L
            requestTimeoutMillis = timeout
            connectTimeoutMillis = timeout
            socketTimeoutMillis = timeout
        }
        install(HttpRequestRetry) {
            retryOnExceptionOrServerErrors(maxRetries = 3)
            exponentialDelay()
        }

        authToken?.let {
            install(Auth) {
                bearer {
                    loadTokens {
                        BearerTokens(authToken, "")
                    }
                }
            }
        }

        install(Logging) {
            level = logLevel
            logger = object : Logger {
                override fun log(message: String) {
                    logVerbose("message = $message")
                }
            }
        }
    }

    sealed class Response<T> {
        data class Success<T>(val data: T) : Response<T>()

        data class Error<T>(val title: String = "", val errorMsg: String, val errorCode: Int) : Response<T>()
    }

    suspend inline fun <reified T> checkResponse(response: HttpResponse): Response<T> =
        if (response.status.isSuccess()) {
            Response.Success(response.body())
        } else {
            try {
                logError("errorResponse=${response.body<String>()}")
                Response.Error(
                    response.status.value.toString(),
                    response.body(),
                    response.status.value
                )
            } catch (e: Exception) {
                logError("errorResponse=${response.body<String>()}")
                Response.Error(
                    errorMsg = response.body<String>().ifBlank { "Something went wrong." },
                    errorCode = response.status.value
                )
            }
        }
}
