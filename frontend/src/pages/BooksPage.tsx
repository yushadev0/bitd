import LibraryPage from "../components/LibraryPage";

export default function BooksPage() {
  return (
    <LibraryPage
      category="books"
      title="Kitaplarım"
      completedLabel="Okunanlar"
      wishlistLabel="Okuma Listesi"
    />
  );
}
