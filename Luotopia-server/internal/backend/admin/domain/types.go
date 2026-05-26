package domain

type Dashboard struct {
	Version   string `json:"version"`
	Uptime    int64  `json:"uptime"`
}

type HealthStatus struct {
	Database bool `json:"database"`
	Redis    bool `json:"redis"`
}
