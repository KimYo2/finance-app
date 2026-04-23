package migrations

import (
	"github.com/pocketbase/dbx"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(db *dbx.DB) error {
		// Seed expense categories
		expenseCategories := []map[string]interface{}{
			{"name": "Makanan", "type": "expense", "icon": "restaurant", "color": "#FF5722", "is_default": true},
			{"name": "Transportasi", "type": "expense", "icon": "directions_car", "color": "#2196F3", "is_default": true},
			{"name": "Belanja", "type": "expense", "icon": "shopping_cart", "color": "#9C27B0", "is_default": true},
			{"name": "Kesehatan", "type": "expense", "icon": "local_hospital", "color": "#F44336", "is_default": true},
			{"name": "Tagihan", "type": "expense", "icon": "receipt", "color": "#FF9800", "is_default": true},
			{"name": "Hiburan", "type": "expense", "icon": "movie", "color": "#E91E63", "is_default": true},
			{"name": "Pendidikan", "type": "expense", "icon": "school", "color": "#3F51B5", "is_default": true},
			{"name": "Lainnya", "type": "expense", "icon": "more_horiz", "color": "#607D8B", "is_default": true},
		}

		// Seed income categories
		incomeCategories := []map[string]interface{}{
			{"name": "Gaji", "type": "income", "icon": "work", "color": "#4CAF50", "is_default": true},
			{"name": "Freelance", "type": "income", "icon": "laptop", "color": "#00BCD4", "is_default": true},
			{"name": "Bonus", "type": "income", "icon": "card_giftcard", "color": "#FFEB3B", "is_default": true},
			{"name": "Usaha", "type": "income", "icon": "business", "color": "#8BC34A", "is_default": true},
			{"name": "Investasi", "type": "income", "icon": "trending_up", "color": "#009688", "is_default": true},
			{"name": "Hadiah", "type": "income", "icon": "card_giftcard", "color": "#E91E63", "is_default": true},
			{"name": "Transfer Masuk", "type": "income", "icon": "swap_horiz", "color": "#8BC34A", "is_default": true},
			{"name": "Lainnya", "type": "income", "icon": "more_horiz", "color": "#607D8B", "is_default": true},
		}

		allCategories := append(expenseCategories, incomeCategories...)

		// Insert each category
		for _, cat := range allCategories {
			_, err := db.Insert("categories", cat).Execute()
			if err != nil {
				// Continue on error (category might already exist)
				continue
			}
		}

		return nil
	}, func(db *dbx.DB) error {
		// Down migration - delete seeded categories
		_, err := db.Delete("categories", dbx.Params{
			"is_default": true,
		}).Execute()
		return err
	})
}