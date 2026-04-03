/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

package com.microsoft.dragoncopilot.sampleapp.network

import com.microsoft.dragoncopilot.sampleapp.network.model.PartnerTokenResponse
import com.microsoft.dragoncopilot.sampleapp.network.model.SoFTokenResponse
import com.microsoft.dragoncopilot.turnkey.logging.Logger.logError
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.request.get
import io.ktor.http.ContentType
import io.ktor.http.contentType

interface AuthTokenService {

    suspend fun getPartnerToken(url: String): NetworkClientProvider.Response<PartnerTokenResponse>

    suspend fun getSofToken(url: String, token: String): NetworkClientProvider.Response<SoFTokenResponse>
}

internal class AuthTokenServiceImpl(
    private val networkClient: NetworkClientProvider = NetworkClientProvider,
    private val engine: HttpClientEngine = OkHttp.create()
) : AuthTokenService {
    override suspend fun getPartnerToken(url: String): NetworkClientProvider.Response<PartnerTokenResponse> = try {
        val response = networkClient.getClient(engine = engine).get(url) {
            contentType(ContentType.Application.Json)
        }
        networkClient.checkResponse<PartnerTokenResponse>(response)
    } catch (e: Exception) {
        logError("Failed to get partner token: ${e.message}")
        NetworkClientProvider.Response.Error(
            errorMsg = "failed to get partner token: ${e.message}",
            errorCode = 0
        )
    }

    override suspend fun getSofToken(url: String, token: String): NetworkClientProvider.Response<SoFTokenResponse> =
        try {
            val response = networkClient.getClient(authToken = token, engine = engine).get(url) {
                contentType(ContentType.Application.Json)
            }
            networkClient.checkResponse<SoFTokenResponse>(response)
        } catch (e: Exception) {
            logError("Failed to get SoF token: ${e.message}")
            NetworkClientProvider.Response.Error(
                errorMsg = "failed to get SoF token: ${e.message}",
                errorCode = 0
            )
        }
}
