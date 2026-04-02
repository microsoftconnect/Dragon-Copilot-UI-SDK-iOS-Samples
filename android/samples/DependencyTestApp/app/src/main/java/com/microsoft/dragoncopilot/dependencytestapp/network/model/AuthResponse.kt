/*
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 */

package com.microsoft.dragoncopilot.dependencytestapp.network.model

import kotlinx.serialization.Serializable

@Serializable
data class PartnerTokenResponse(val token: String)

@Serializable
data class SoFTokenResponse(val issuer: String, val launch: String)
