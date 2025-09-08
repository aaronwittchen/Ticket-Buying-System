-- Insert initial venues
INSERT INTO venue (name, address, total_capacity)
VALUES
    ('Old Trafford', 'Manchester, UK', 80000),
    ('Etihad Stadium', 'Manchester, UK', 70000);

-- Insert initial events
INSERT INTO event (name, venue_id, total_capacity, left_capacity, ticket_price)
VALUES
    ('Coldplay', 1, 40000, 40000, 15.00),
    ('Bruno Mars', 2, 30000, 30000, 12.50);
