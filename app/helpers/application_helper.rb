module ApplicationHelper
  def provider_logos
    {
      "Disney Plus" => ["providers/disneyplus.webp", "Disney Plus", "https://www.disneyplus.com/fr-fr"],
      "Netflix" => ["providers/netflix.webp", "Netflix", "https://www.netflix.com"],
      "Apple TV+" => ["providers/appletv.webp", "Apple TV", "https://tv.apple.com/fr"],
      "Amazon Prime Video" => ["providers/primevideo.webp", "Amazon Prime Video", "https://www.primevideo.com"],
      "Canal+" => ["providers/canalplus.webp", "Canal+", "https://www.canalplus.com/"],
      "HBO Max" => ["providers/max.webp", "HBO Max", "https://www.hbomax.com/fr/fr"],
      "TF1+" => ["providers/tf1.webp", "TF1+", "https://www.tf1.fr"],
      "Paramount Plus" => ["providers/paramount.webp", "Paramount Plus", "https://www.paramountplus.com/fr"],
      "Crunchyroll" => ["providers/crunchyroll.webp", "Crunchyroll", "https://www.crunchyroll.com/fr"]
    }
  end
end
