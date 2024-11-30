package br.com.sigas.repositories;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import br.com.sigas.entities.Produtos;

@Repository
public interface ProdutosRepository extends JpaRepository<Produtos, Long> {

        @Procedure(procedureName = "inserir_produto")
        void inserirProduto(
                        @Param("nome_produto") String nomeProduto,
                        @Param("descricao") String descricao,
                        @Param("unidade") String unidade,
                        @Param("preco_unidade") BigDecimal precoUnidade,
                        @Param("qtd_estoque") Integer qtdEstoque,
                        @Param("id_categoria") Long idCategoria);

        @Query("SELECT p FROM Produtos p WHERE p.id_produto = :id")
        Optional<Produtos> buscarProdutoPorId(@Param("id") Long id);

        @Query("SELECT p FROM Produtos p WHERE LOWER(p.nome_produto) LIKE LOWER(CONCAT('%', :nome, '%'))")
        List<Produtos> buscarProdutoPorNome(@Param("nome") String nome);

        @Query("SELECT p FROM Produtos p WHERE p.categoria.id_categoria = :idCategoria")
        List<Produtos> buscarProdutosPorCategoria(@Param("idCategoria") Long idCategoria);

        @Procedure(procedureName = "atualizar_produto")
        void atualizarProduto(
                        @Param("id_produto") Long idProduto,
                        @Param("nome_produto") String nomeProduto,
                        @Param("descricao") String descricao,
                        @Param("unidade") String unidade,
                        @Param("preco_unidade") BigDecimal precoUnidade,
                        @Param("qtd_estoque") Integer qtdEstoque);

        @Procedure(procedureName = "deletar_produto")
        void deletarProduto(@Param("id_produto") Long idProduto);
}
