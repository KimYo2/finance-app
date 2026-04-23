package migrations

import (
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(db *dbx.DB) error {
		// Create transactions table
		_, err := db.Exec(`
			CREATE TABLE IF NOT EXISTS transactions (
				id TEXT PRIMARY KEY NOT NULL,
				created TEXT NOT NULL,
				updated TEXT NOT NULL,
				title TEXT NOT NULL,
				amount REAL NOT NULL,
				type TEXT NOT NULL,
				category TEXT NOT NULL,
				date TEXT NOT NULL,
				note TEXT DEFAULT ''
			)
		`)
		if err != nil {
			return err
		}

		// Create indexes for transactions
		db.Exec(`CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions (date)`)
		db.Exec(`CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions (type)`)

		// Create categories table
		_, err = db.Exec(`
			CREATE TABLE IF NOT EXISTS categories (
				id TEXT PRIMARY KEY NOT NULL,
				created TEXT NOT NULL,
				updated TEXT NOT NULL,
				name TEXT NOT NULL,
				type TEXT NOT NULL,
				icon TEXT DEFAULT '',
				color TEXT DEFAULT '#607D8B',
				is_default INTEGER DEFAULT 1
			)
		`)
		if err != nil {
			return err
		}

		// Create indexes for categories
		db.Exec(`CREATE INDEX IF NOT EXISTS idx_categories_type ON categories (type)`)

		return nil
	}, func(db *dbx.DB) error {
		dao := daos.New(db)
		
		// First delete transactions to handle foreign key if needed
		if err := dao.DeleteCollection("transactions"); err != nil {
			// Ignore error if collection doesn't exist
			_ = dao.DeleteCollection("transactions")
		}
		
		if err := dao.DeleteCollection("categories"); err != nil {
			_ = dao.DeleteCollection("categories")
		}
		
		return nil
	})
}