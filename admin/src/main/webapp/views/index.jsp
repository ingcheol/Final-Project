<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Dashboard | Osen</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f6fa;
            color: #333;
        }

        .container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
            color: #fff;
            padding: 20px 0;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
        }

        .logo {
            padding: 0 20px 30px;
            font-size: 24px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo::before {
            content: "●";
            color: #6366f1;
            font-size: 30px;
        }

        .nav-section {
            margin-bottom: 30px;
        }

        .nav-title {
            padding: 10px 20px;
            font-size: 11px;
            text-transform: uppercase;
            color: #94a3b8;
            letter-spacing: 1px;
        }

        .nav-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #cbd5e1;
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
        }

        .nav-item:hover {
            background: rgba(99, 102, 241, 0.1);
            color: #fff;
        }

        .nav-item.active {
            background: rgba(99, 102, 241, 0.2);
            color: #fff;
            border-left: 3px solid #6366f1;
        }

        .nav-item.active::before {
            content: "●";
            position: absolute;
            right: 20px;
            color: #22c55e;
            font-size: 12px;
        }

        .nav-item .icon {
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Main Content Styles */
        .main-content {
            margin-left: 260px;
            flex: 1;
            padding: 20px 30px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background: #fff;
            padding: 15px 25px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .search-bar {
            display: flex;
            align-items: center;
            background: #f1f5f9;
            padding: 10px 15px;
            border-radius: 8px;
            width: 300px;
        }

        .search-bar input {
            border: none;
            background: none;
            outline: none;
            margin-left: 10px;
            width: 100%;
        }

        .header-actions {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .icon-btn {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            border: none;
            background: #f1f5f9;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }

        .icon-btn:hover {
            background: #e2e8f0;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: #fff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #6366f1, #8b5cf6);
        }

        .stat-label {
            color: #64748b;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        .stat-card:nth-child(1) .stat-icon {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
        }

        .stat-card:nth-child(2) .stat-icon {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: #fff;
        }

        .stat-card:nth-child(3) .stat-icon {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: #fff;
        }

        .stat-card:nth-child(4) .stat-icon {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            color: #fff;
        }

        .stat-change {
            font-size: 13px;
            color: #22c55e;
        }

        .stat-change.negative {
            color: #ef4444;
        }

        .stat-change::before {
            content: "↑ ";
        }

        .stat-change.negative::before {
            content: "↓ ";
        }

        /* Cards Grid */
        .cards-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .card {
            background: #fff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            color: #1e293b;
        }

        .card-actions {
            display: flex;
            gap: 10px;
        }

        /* Chart Placeholder */
        .chart-container {
            height: 300px;
            background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }

        .chart-bars {
            display: flex;
            align-items: flex-end;
            gap: 20px;
            height: 200px;
        }

        .chart-bar {
            width: 40px;
            background: linear-gradient(180deg, #6366f1 0%, #8b5cf6 100%);
            border-radius: 8px 8px 0 0;
            animation: growBar 1s ease-out;
        }

        @keyframes growBar {
            from { height: 0; }
            to { height: var(--height); }
        }

        /* Traffic Chart */
        .traffic-chart {
            width: 200px;
            height: 200px;
            margin: 20px auto;
            position: relative;
        }

        .donut-chart {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            background: conic-gradient(
                    #6366f1 0deg 130deg,
                    #8b5cf6 130deg 230deg,
                    #22c55e 230deg 290deg,
                    #ef4444 290deg 360deg
            );
            position: relative;
        }

        .donut-chart::after {
            content: "";
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 60%;
            height: 60%;
            background: #fff;
            border-radius: 50%;
        }

        .traffic-legend {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-top: 20px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
        }

        .legend-color {
            width: 12px;
            height: 12px;
            border-radius: 3px;
        }

        /* Table Styles */
        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: #f8fafc;
        }

        th {
            padding: 15px;
            text-align: left;
            font-size: 12px;
            text-transform: uppercase;
            color: #64748b;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        td {
            padding: 18px 15px;
            border-bottom: 1px solid #f1f5f9;
            color: #475569;
        }

        tr:hover {
            background: #f8fafc;
        }

        .brand-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .brand-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: #fff;
        }

        .status-badge {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
        }

        .status-active {
            background: #d1fae5;
            color: #065f46;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .cards-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .main-content {
                margin-left: 0;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="logo">OSEN</div>

        <div class="nav-section">
            <div class="nav-title">DASH</div>
            <div class="nav-item active">
                <span class="icon">📊</span>
                <span>Sales</span>
            </div>
            <div class="nav-item">
                <span class="icon">🏥</span>
                <span>Clinic</span>
            </div>
            <div class="nav-item">
                <span class="icon">📱</span>
                <span>eWallet</span>
            </div>
        </div>

        <div class="nav-section">
            <div class="nav-title">APPS & PAGES</div>
            <div class="nav-item">
                <span class="icon">💬</span>
                <span>Chat</span>
            </div>
            <div class="nav-item">
                <span class="icon">📅</span>
                <span>Calendar</span>
            </div>
            <div class="nav-item">
                <span class="icon">✉️</span>
                <span>Email</span>
            </div>
            <div class="nav-item">
                <span class="icon">📁</span>
                <span>File Manager</span>
            </div>
        </div>

        <div class="nav-section">
            <div class="nav-title">COMPONENTS</div>
            <div class="nav-item">
                <span class="icon">🧩</span>
                <span>Base UI</span>
            </div>
            <div class="nav-item">
                <span class="icon">📋</span>
                <span>Forms</span>
            </div>
            <div class="nav-item">
                <span class="icon">📊</span>
                <span>Charts</span>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- Header -->
        <header class="header">
            <div class="search-bar">
                <span>🔍</span>
                <input type="text" placeholder="Search something...">
            </div>
            <div class="header-actions">
                <button class="icon-btn">🌙</button>
                <button class="icon-btn">🔔</button>
                <button class="icon-btn">⚙️</button>
                <button class="icon-btn">👤</button>
            </div>
        </header>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Orders</div>
                <div class="stat-value">
                    <div class="stat-icon">📦</div>
                    <span>687.3k</span>
                </div>
                <div class="stat-change">9.19% Since last month</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Total Returns</div>
                <div class="stat-value">
                    <div class="stat-icon">↩️</div>
                    <span>9.62k</span>
                </div>
                <div class="stat-change negative">26.87% Since last month</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Avg. Sales Earnings</div>
                <div class="stat-value">
                    <div class="stat-icon">💰</div>
                    <span>$98.24</span>
                </div>
                <div class="stat-change">3.51% Since last month</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Number of Visits</div>
                <div class="stat-value">
                    <div class="stat-icon">👁️</div>
                    <span>87.94M</span>
                </div>
                <div class="stat-change">1.05% Since last month</div>
            </div>
        </div>

        <!-- Cards Grid -->
        <div class="cards-grid">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Overview</h3>
                    <div class="card-actions">
                        <button class="icon-btn">⋮</button>
                    </div>
                </div>
                <div class="chart-container">
                    <div class="chart-bars">
                        <div class="chart-bar" style="--height: 80px"></div>
                        <div class="chart-bar" style="--height: 120px"></div>
                        <div class="chart-bar" style="--height: 100px"></div>
                        <div class="chart-bar" style="--height: 150px"></div>
                        <div class="chart-bar" style="--height: 90px"></div>
                        <div class="chart-bar" style="--height: 130px"></div>
                        <div class="chart-bar" style="--height: 110px"></div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Top Traffic by Source</h3>
                    <div class="card-actions">
                        <button class="icon-btn">⋮</button>
                    </div>
                </div>
                <div class="traffic-chart">
                    <div class="donut-chart"></div>
                </div>
                <div class="traffic-legend">
                    <div class="legend-item">
                        <span class="legend-color" style="background: #6366f1"></span>
                        <span>Direct</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background: #8b5cf6"></span>
                        <span>Marketing</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background: #22c55e"></span>
                        <span>Social</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background: #ef4444"></span>
                        <span>Affiliates</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Brands Listing Table -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Brands Listing</h3>
                <button class="btn-primary">+ Add Brand</button>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                    <tr>
                        <th>Category</th>
                        <th>Brand Name</th>
                        <th>Established</th>
                        <th>Stores</th>
                        <th>Products</th>
                        <th>Status</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td>
                            <div class="brand-cell">
                                <div class="brand-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%)">Z</div>
                                <div>
                                    <div style="font-weight: 600">Clothing</div>
                                    <div style="font-size: 12px; color: #94a3b8">Zaroan - Brazil</div>
                                </div>
                            </div>
                        </td>
                        <td>Since 2020</td>
                        <td>1.5k</td>
                        <td>8,950</td>
                        <td><span class="status-badge status-active">Active</span></td>
                        <td><button class="icon-btn">⋮</button></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="brand-cell">
                                <div class="brand-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%)">J</div>
                                <div>
                                    <div style="font-weight: 600">Clothing</div>
                                    <div style="font-size: 12px; color: #94a3b8">Jocky-Johns - USA</div>
                                </div>
                            </div>
                        </td>
                        <td>Since 1985</td>
                        <td>205</td>
                        <td>1,258</td>
                        <td><span class="status-badge status-active">Active</span></td>
                        <td><button class="icon-btn">⋮</button></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="brand-cell">
                                <div class="brand-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)">G</div>
                                <div>
                                    <div style="font-weight: 600">Lifestyle</div>
                                    <div style="font-size: 12px; color: #94a3b8">Ginne - India</div>
                                </div>
                            </div>
                        </td>
                        <td>Since 2001</td>
                        <td>89</td>
                        <td>338</td>
                        <td><span class="status-badge status-active">Active</span></td>
                        <td><button class="icon-btn">⋮</button></td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>
</body>
</html>