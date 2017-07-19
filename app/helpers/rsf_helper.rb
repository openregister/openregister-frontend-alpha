module RsfHelper

  include HTTParty
  require 'json'

  DOWNLOAD_RSF_URL = 'https://country.register.gov.uk/download-rsf'

  def get_entries page_number=1

    rsf = HTTParty.get(DOWNLOAD_RSF_URL)

    items = []
    entries = []

    rsf.each_line do |line|
      line.slice!("\n")
      command = line.split("\t")[0]

      if command == 'add-item'
        items << parse_item(line.split("\t")[1])
      elsif command == 'append-entry'
        if line.split("\t")[1] == 'user'
          entries << [line.split("\t")[2], line.split("\t")[4]]
        end
      end
    end

    map_entries_and_items(entries, items).reverse

  end

  def map_entries_and_items(entries, items)
    mapped_entries = entries.map { |entry|
      parse_entry(entry[0],
                  entry[1],
                  JSON.parse(items.find { |item| item[:hash] == entry[1]}[:item]),
                  find_last_historic_item(entry[0], entry[1], entries, items)
      )
    }

    mapped_entries
  end

  def find_last_historic_item(key, hash, entries, items)
    current_item_index = entries.index{ |entry|
      entry[1] == hash }

    historic_entries = entries.slice(0, current_item_index)

    most_recent_entry = historic_entries.find { |entry|
      entry[0] == key }

    unless most_recent_entry.nil?
      JSON.parse(items.find{ |item|
        item[:hash] == most_recent_entry[1] }[:item])
    end
  end

  def parse_item item_json
    payload_sha = Digest::SHA256.hexdigest item_json
    { hash: 'sha-256:' + payload_sha, item: item_json }
  end

  def parse_entry(key, hash, current_item, previous_item)
    { key: key, hash: hash, current_item: current_item, previous_item: previous_item }
  end

end