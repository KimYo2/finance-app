package migrations

import (
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(db *dbx.DB) error {
		// Create assets table
		_, err := db.Exec(`
			CREATE TABLE IF NOT EXISTS assets (
				id TEXT PRIMARY KEY NOT NULL,
				created TEXT NOT NULL,
				updated TEXT NOT NULL,
				name TEXT NOT NULL,
				type TEXT NOT NULL,
				amount REAL NOT NULL,
				currency TEXT DEFAULT 'IDR',
				purchase_date TEXT,
				note TEXT DEFAULT '',
				is_active INTEGER DEFAULT 1
			)
		`)
		if err != nil {
			return err
		}

		db.Exec(`CREATE INDEX IF NOT EXISTS idx_assets_type ON assets (type)`)
		db.Exec(`CREATE INDEX IF NOT EXISTS idx_assets_is_active ON assets (is_active)`)

		// Create debts table
		_, err = db.Exec(`
			CREATE TABLE IF NOT EXISTS debts (
				id TEXT PRIMARY KEY NOT NULL,
				created TEXT NOT NULL,
				updated TEXT NOT NULL,
				title TEXT NOT NULL,
				type TEXT NOT NULL,
				amount REAL NOT NULL,
				remaining_amount REAL,
				person_name TEXT DEFAULT '',
				due_date TEXT,
				start_date TEXT,
				is_paid INTEGER DEFAULT 0,
				note TEXT DEFAULT ''
			)
		`)
		if err != nil {
			return err
		}

		db.Exec(`CREATE INDEX IF NOT EXISTS idx_debts_type ON debts (type)`)
		db.Exec(`CREATE INDEX IF NOT EXISTS idx_debts_is_paid ON debts (is_paid)`)

		// Create budgets table
		_, err = db.Exec(`
			CREATE TABLE IF NOT EXISTS budgets (
				id TEXT PRIMARY KEY NOT NULL,
				created TEXT NOT NULL,
				updated TEXT NOT NULL,
				name TEXT NOT NULL,
				amount REAL NOT NULL,
				spent REAL DEFAULT 0,
				category TEXT DEFAULT '',
				month INTEGER NOT NULL,
				year INTEGER NOT NULL,
				note TEXT DEFAULT '',
				is_active INTEGER DEFAULT 1
			)
		`)
		if err != nil {
			return err
		}

		db.Exec(`CREATE INDEX IF NOT EXISTS idx_budgets_month_year ON budgets (month, year)`)
		db.Exec(`CREATE INDEX IF NOT EXISTS idx_budgets_is_active ON budgets (is_active)`)

		return nil
	}, func(db *dbx.DB) error {
		dao := daos.New(db)

		if err := dao.DeleteCollection("assets"); err != nil {
			_ = dao.DeleteCollection("assets")
		}

		if err := dao.DeleteCollection("debts"); err != nil {
			_ = dao.DeleteCollection("debts")
		}

		if err := dao.DeleteCollection("budgets"); err != nil {
			_ = dao.DeleteCollection("budgets")
		}

		return nil
	})
}